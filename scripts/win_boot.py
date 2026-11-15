"""Checks and the requirements stamp for run.bat and build_windows.bat.

Those batch files must not pass Python source on a python -c line. cmd.exe
treats "for" and angle brackets in that string as its own syntax, then reports
that a file is missing and that dependency installation failed.
"""

from __future__ import annotations

import shutil
import sys


def version_ok() -> int:
    return 0 if sys.version_info >= (3, 12) else 1


def print_executable() -> int:
    print(sys.executable)
    return 0


def pyinstaller_ok() -> int:
    # Drop "" so a local PyInstaller.py cannot pretend the package is installed.
    sys.path = [entry for entry in sys.path if entry]
    try:
        __import__("PyInstaller")
    except Exception as exc:
        print("PyInstaller (%s)" % exc)
        return 1
    return 0


def imports_ok() -> int:
    # Drop "" so a file in the current directory cannot pretend to be an installed package.
    sys.path = [entry for entry in sys.path if entry]
    problems: list[str] = []
    for name in ("can", "serial"):
        try:
            __import__(name)
        except Exception as exc:
            problems.append("%s (%s)" % (name, exc))
    try:
        from PySide6 import QtWidgets
    except Exception as exc:
        problems.append("PySide6 (%s)" % exc)
    else:
        if QtWidgets is None:
            problems.append("PySide6")
    if problems:
        print("These modules failed to load:")
        for item in problems:
            print("  " + item)
        return 1
    return 0


def write_stamp(src: str, dest: str) -> int:
    try:
        shutil.copyfile(src, dest)
    except OSError as exc:
        print("Could not save the requirements stamp: %s" % exc)
        return 1
    return 0


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: win_boot.py version|exe|imports|pyinstaller|stamp SRC DST")
        return 2
    command = argv[1]
    if command == "version":
        return version_ok()
    if command == "exe":
        return print_executable()
    if command == "imports":
        return imports_ok()
    if command == "pyinstaller":
        return pyinstaller_ok()
    if command == "stamp":
        if len(argv) != 4:
            print("usage: win_boot.py stamp SRC DST")
            return 2
        return write_stamp(argv[2], argv[3])
    print("Unknown win_boot command: %s" % command)
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
