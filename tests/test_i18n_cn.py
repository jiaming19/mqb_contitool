"""Chinese (`-l cn`) language selection."""

from __future__ import annotations

import sys

import pytest

from contitool.cli.main import build_arg_parser
from contitool.core import dtc
from contitool.i18n import apply_startup_lang, get_lang, normalize_lang_code, set_lang, tr


@pytest.fixture(autouse=True)
def _restore_lang():
    previous = get_lang()
    yield
    set_lang(previous)


def test_normalize_chinese_codes() -> None:
    assert normalize_lang_code("cn") == "cn"
    assert normalize_lang_code("CN") == "cn"
    assert normalize_lang_code("zh") == "cn"
    assert normalize_lang_code("zh-CN") == "cn"
    assert normalize_lang_code("zh_cn") == "cn"
    assert normalize_lang_code("中文") == "cn"
    assert normalize_lang_code("de") is None


def test_set_lang_cn_translates_exact_and_template() -> None:
    set_lang("cn")
    assert get_lang() == "cn"
    assert tr("Файл", "File") == "文件"
    assert tr("Открыть блок", "Open an ECU") == "打开控制单元"
    assert tr("Язык: ru / en / cn", "Language: ru / en / cn") == "语言：ru / en / cn"
    assert "1.2" in tr(f"{1.2:.1f} с", f"{1.2:.1f} s")
    assert tr(f"{1.2:.1f} с", f"{1.2:.1f} s") != "1.2 s"

    set_lang("en")
    assert tr("Файл", "File") == "File"
    set_lang("ru")
    assert tr("Файл", "File") == "Файл"


def test_dtc_descriptions_follow_chinese() -> None:
    set_lang("cn")
    display, text = dtc.describe(0x000101)
    assert display.startswith("B200044")
    assert text == "内部故障：RAM"
    assert dtc.status_text(0x09) != "active now, confirmed"
    set_lang("en")
    assert dtc.status_text(0x09) == "active now, confirmed"
    set_lang("ru")
    assert dtc.describe(0x020257) == ("U023500", "Нет связи с блоком 13 — адаптивный круиз-контроль (ACC)")


def test_explicit_cn_argument_overrides_catalog() -> None:
    set_lang("cn")
    assert tr("Файл", "File", "档案") == "档案"


def test_cli_accepts_cn_and_zh() -> None:
    parser = build_arg_parser()
    assert parser.parse_args(["-l", "cn", "banks"]).lang == "cn"
    assert parser.parse_args(["--lang", "zh", "banks"]).lang == "cn"
    assert parser.parse_args(["gui", "-l", "cn"]).lang == "cn"
    with pytest.raises(SystemExit):
        parser.parse_args(["-l", "de", "banks"])


def test_unknown_language_is_rejected() -> None:
    with pytest.raises(ValueError):
        set_lang("de")


def test_windows_release_defaults_to_chinese(monkeypatch: pytest.MonkeyPatch) -> None:
    set_lang("ru")
    monkeypatch.setattr(sys, "frozen", True, raising=False)
    monkeypatch.setattr(sys, "platform", "win32")
    apply_startup_lang([])
    assert get_lang() == "cn"


def test_windows_release_keeps_explicit_language(monkeypatch: pytest.MonkeyPatch) -> None:
    set_lang("ru")
    monkeypatch.setattr(sys, "frozen", True, raising=False)
    monkeypatch.setattr(sys, "platform", "win32")
    apply_startup_lang(["-l", "en"])
    assert get_lang() == "en"
    apply_startup_lang(["--lang=ru"])
    assert get_lang() == "ru"


def test_source_and_other_releases_do_not_switch_to_chinese(monkeypatch: pytest.MonkeyPatch) -> None:
    set_lang("en")
    monkeypatch.delattr(sys, "frozen", raising=False)
    apply_startup_lang([])
    assert get_lang() == "en"
    set_lang("ru")
    monkeypatch.setattr(sys, "frozen", True, raising=False)
    monkeypatch.setattr(sys, "platform", "darwin")
    apply_startup_lang([])
    assert get_lang() == "ru"
