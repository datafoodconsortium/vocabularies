#===============================================================================
#
#          FILE: validate_taxonomy.py
#
#         USAGE: python validate_taxonomy.py <json_ld_file>
#
#   DESCRIPTION: Validates JSON-LD taxonomies following DFC naming conventions:
#                - Must be valid JSON-LD
#                - URIs must be alphanumeric and start with a letter
#                - Classes use PascalCase
#                - Properties use camelCase
#
#===============================================================================

from dataclasses import dataclass
from enum import Enum
from pathlib import Path
import json
import re
import sys
from typing import List, Dict, Optional

class NamingPattern(Enum):
    ALPHANUM = (
        r'^(?:dfc-m:)?[a-zA-Z][a-zA-Z0-9]*$',
        "Must be alphanumeric starting with a letter"
    )
    PASCAL = (
        r'^(?:dfc-m:)?[A-Z][a-zA-Z0-9]*$',
        "Concepts must use PascalCase"
    )
    CAMEL = (
        r'^(?:dfc-m:)?[a-z][a-zA-Z0-9]*$',
        "Properties must use camelCase"
    )

    def __init__(self, pattern: str, message: str):
        self.pattern = pattern
        self.message = message

@dataclass
class ValidationError:
    message: str
    identifier: str = ""
    line: int = 0

class JSONLDParser:
    def __init__(self, content: str):
        self.content = content
        self.id_lines = self._map_ids_to_lines()
        self.data = json.loads(content)

    def _map_ids_to_lines(self) -> Dict[int, str]:
        return {
            line_num: line 
            for line_num, line in enumerate(self.content.split('\n'), 1)
            if '"@id"' in line
        }

    def get_node(self, uri: str) -> dict:
        if '@graph' not in self.data:
            return {}
        return next((node for node in self.data['@graph'] 
                    if node.get('@id') == uri), {})

    def get_line_number(self, uri: str) -> int:
        return next((num for num, line in self.id_lines.items() 
                    if uri in line), 0)

class TaxonomyValidator:
    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        self.errors: List[ValidationError] = []
        
    def validate(self) -> bool:
        try:
            with open(self.file_path) as f:
                self.parser = JSONLDParser(f.read())
            return self._validate_uris()
        except json.JSONDecodeError as e:
            self.errors.append(
                ValidationError(f"Invalid JSON: {e.msg}", line=e.lineno)
            )
            return False

    def _validate_uris(self) -> bool:
        seen_uris = set()
        is_valid = True

        for uri in self._extract_uris(self.parser.data):
            identifier = self._get_identifier(uri)
            if not identifier or identifier in seen_uris:
                continue

            seen_uris.add(identifier)
            if not self._validate_naming_patterns(uri, identifier):
                is_valid = False

        return is_valid

    def _validate_naming_patterns(self, uri: str, identifier: str) -> bool:
        node = self.parser.get_node(uri)
        line = self.parser.get_line_number(uri)

        # Basic alphanumeric check
        if not re.match(NamingPattern.ALPHANUM.pattern, identifier):
            self.errors.append(ValidationError(
                NamingPattern.ALPHANUM.message, identifier, line
            ))
            return False

        # Concept check
        if 'skos:Concept' in node.get('@type', []):
            if not re.match(NamingPattern.PASCAL.pattern, identifier):
                self.errors.append(ValidationError(
                    NamingPattern.PASCAL.message, identifier, line
                ))
                return False

        return True

    @staticmethod
    def _get_identifier(uri: str) -> str:
        if '#' in uri.split('/')[-1]:
            return uri.split('/')[-1].split('#')[-1]
        return ''

    def _extract_uris(self, data) -> List[str]:
        if isinstance(data, dict):
            return ([data['@id']] if '@id' in data else []) + [
                uri for value in data.values()
                if isinstance(value, (dict, list))
                for uri in self._extract_uris(value)
            ]
        elif isinstance(data, list):
            return [uri for item in data for uri in self._extract_uris(item)]
        return []

def main():
    if len(sys.argv) != 2:
        print("Usage: python validate_taxonomy.py <json_ld_file>")
        sys.exit(1)

    tv = TaxonomyValidator(sys.argv[1])
    if tv.validate():
        print(f"\n✨ PASS {tv.file_path.name} is valid!")
        sys.exit(0)

    print(f"\n❌ FAIL Found {len(tv.errors)} issues in {tv.file_path.name}:\n")
    for error in tv.errors:
        message = f"    [L{error.line}]\t{error.message}"
        if error.identifier:
            message += f" (in '{error.identifier}')"
        print(message)
    sys.exit(1)

if __name__ == "__main__":
    main()