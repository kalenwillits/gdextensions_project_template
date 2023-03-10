import os
from pathlib import Path


class gdclass:
    def __init__(self, name, path):
        self.name = name
        self.path = path




def get_source_files(path_string="src/"):
    result = {}
    path = Path(path_string)
    for filename in os.listdir(path):
        if os.path.isdir(path / filename):
            result.update(get_source_files(path / filename))
        else:
            class

