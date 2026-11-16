"""RU / EN / CN localization state with live UI observer support.

Chinese (`-l cn`) is a catalog keyed by the English text. Exact strings hit the
catalog directly. f-strings are stored as templates with `{0}`, `{1}`, … and
matched back onto the formatted English at runtime.
"""

from __future__ import annotations

from collections.abc import Callable
import json
import os
from pathlib import Path
import re
import sys
import types
import weakref

_LANG: str = "ru"
_LISTENERS: list[Callable[[str], None] | weakref.WeakMethod] = []
_LANGS = ("ru", "en", "cn")

_PH_RE = re.compile(r"\{(\d+)\}")
_EXACT: dict[str, str] = {}
# (regex, chinese template, stripped literal length, placeholder count, english template)
_TEMPLATES: list[tuple[re.Pattern[str], str, int, int, str]] = []
_CN_LOADED = False


def normalize_lang_code(raw: str | None) -> str | None:
    """Normalize arbitrary language code strings into 'ru', 'en', or 'cn'."""
    if raw is None:
        return None
    val = raw.strip().lower().replace("_", "-")
    if val in ("ru", "rus", "russian", "р", "ру", "рус", "русский", "1"):
        return "ru"
    if val in ("en", "eng", "english", "англ", "2"):
        return "en"
    if val in ("cn", "zh", "zh-cn", "zhcn", "chinese", "chs", "zh-hans", "中文", "汉语", "简体", "简体中文"):
        return "cn"
    return None


def set_lang(lang: str) -> str:
    """Set active language ('ru', 'en', or 'cn') and notify registered UI listeners."""
    global _LANG
    norm = normalize_lang_code(lang)
    if norm not in _LANGS:
        raise ValueError(
            f"Unsupported language / Неподдерживаемый язык / 不支持的语言: {lang!r} "
            "(use 'ru', 'en', or 'cn')"
        )
    changed = norm != _LANG
    _LANG = norm
    if changed:
        alive: list[Callable[[str], None] | weakref.WeakMethod] = []
        for entry in list(_LISTENERS):
            if isinstance(entry, weakref.WeakMethod):
                cb = entry()
                if cb is None:
                    continue
                try:
                    cb(_LANG)
                except RuntimeError:
                    # Underlying C++ Qt widget was already destroyed
                    continue
                alive.append(entry)
            else:
                try:
                    entry(_LANG)
                except RuntimeError:
                    # Underlying C++ Qt widget was already destroyed
                    continue
                alive.append(entry)
        _LISTENERS[:] = alive
    return _LANG


def get_lang() -> str:
    """Return active language code ('ru', 'en', or 'cn')."""
    return _LANG


def _captures_ok(groups: tuple[str, ...], lit_len: int) -> bool:
    """Reject loose skeletons that would swallow a whole sentence."""
    for group in groups:
        if len(group) > 500:
            return False
        if lit_len < 20 and "\n" in group:
            return False
    if lit_len >= 12:
        return True
    for group in groups:
        if len(group) > 64:
            return False
        if lit_len < 4 and re.fullmatch(r"\d+(?:\.\d+)?", group) is None:
            return False
    return True


def _compile_templates(items: list[dict[str, str]]) -> list[tuple[re.Pattern[str], str, int, int, str]]:
    compiled: list[tuple[re.Pattern[str], str, int, int, str]] = []
    for item in items:
        en = item.get("en") or ""
        cn = item.get("cn") or ""
        if not en or not cn:
            continue
        parts = _PH_RE.split(en)
        if len(parts) < 3:
            continue
        literals = parts[0::2]
        nums = parts[1::2]
        if any(not num.isdigit() for num in nums):
            continue
        buf = ["^"]
        for i, lit in enumerate(literals):
            buf.append(re.escape(lit))
            if i < len(nums):
                buf.append("(.*?)")
        buf.append("$")
        try:
            pattern = re.compile("".join(buf), re.DOTALL)
        except re.error:
            continue
        lit_len = len(re.sub(r"\{\d+\}", "", en).strip())
        compiled.append((pattern, cn, lit_len, len(nums), en))
    compiled.sort(key=lambda row: (row[2], row[3], len(row[4])), reverse=True)
    return compiled


def _catalog_path() -> Path:
    """Source tree, or the copy PyInstaller places at the bundle root."""
    bundled = getattr(sys, "_MEIPASS", None)
    if bundled:
        packed = Path(bundled) / "i18n_cn.json"
        if packed.is_file():
            return packed
    return Path(__file__).with_name("i18n_cn.json")


def _ensure_cn() -> None:
    global _CN_LOADED
    if _CN_LOADED:
        return
    path = _catalog_path()
    if not path.is_file():
        _CN_LOADED = True
        return
    data = json.loads(path.read_text(encoding="utf-8"))
    _CN_LOADED = True
    exact = data.get("exact") or {}
    if isinstance(exact, dict):
        _EXACT.update({str(k): str(v) for k, v in exact.items() if isinstance(v, str) and v})
    templates = data.get("templates") or []
    if isinstance(templates, list):
        _TEMPLATES.extend(_compile_templates([row for row in templates if isinstance(row, dict)]))


def _from_template(text: str) -> str | None:
    for pattern, cn, lit_len, _nph, _en in _TEMPLATES:
        matched = pattern.fullmatch(text)
        if matched is None:
            continue
        groups = matched.groups()
        if not _captures_ok(groups, lit_len):
            continue

        def _sub(mo: re.Match[str], groups: tuple[str, ...] = groups) -> str:
            index = int(mo.group(1))
            if 0 <= index < len(groups):
                return groups[index]
            return mo.group(0)

        return _PH_RE.sub(_sub, cn)
    return None


def tr(ru: str, en: str, cn: str | None = None) -> str:
    """Return the string for the active language.

    `cn`, when passed, is used as-is for Chinese. Otherwise Chinese comes from
    the catalog, and falls back to English when a line has no translation yet.
    """
    if _LANG == "en":
        return en
    if _LANG == "cn":
        if cn:
            return cn
        _ensure_cn()
        hit = _EXACT.get(en)
        if hit is not None:
            return hit
        templated = _from_template(en)
        if templated is not None:
            return templated
        return en
    return ru


def subscribe_lang_change(callback: Callable[[str], None]) -> Callable[[], None]:
    """Register a callback invoked whenever `set_lang` changes the active language."""
    entry: Callable[[str], None] | weakref.WeakMethod = (
        weakref.WeakMethod(callback) if isinstance(callback, types.MethodType) else callback
    )
    _LISTENERS.append(entry)

    def _unsubscribe() -> None:
        if entry in _LISTENERS:
            _LISTENERS.remove(entry)

    return _unsubscribe


def detect_early_cli_lang(argv: list[str]) -> str | None:
    """Inspect argv / CONTI_CP_LANG before building argparse so `--help` is localized."""
    for i, tok in enumerate(argv):
        if tok in ("-l", "--lang") and i + 1 < len(argv):
            got = normalize_lang_code(argv[i + 1])
            if got:
                return got
        elif tok.startswith("--lang="):
            got = normalize_lang_code(tok.split("=", 1)[1])
            if got:
                return got
    return normalize_lang_code(os.environ.get("CONTI_CP_LANG"))


def apply_startup_lang(argv: list[str]) -> None:
    """Apply `-l` / `CONTI_CP_LANG`. A Windows release with neither starts in Chinese."""
    chosen = detect_early_cli_lang(argv)
    if chosen:
        set_lang(chosen)
    elif getattr(sys, "frozen", False) and sys.platform == "win32":
        set_lang("cn")
