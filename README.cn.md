<div align="center">

# ContiTool v2.1 — Continental VAG MQB Gateway J533 (`3Q0 907 530`)
### Renesas RH850/F1L — Diagnosis CAN Studio, Component Protection (`KSCHUTZ`), Engineering Mode & `SWaP / RSA-1024`

[![Russian README](https://img.shields.io/badge/lang-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-2563EB?style=for-the-badge)](README.md)
[![English README](https://img.shields.io/badge/lang-English-2563EB?style=for-the-badge)](README.en.md)
[![GUI + CLI](https://img.shields.io/badge/Desktop%20GUI%20%2B%20CLI-Windows%20%7C%20macOS%20%7C%20Linux-0EA5E9?style=for-the-badge)](#使用步骤)
[![MCU RH850/F1L](https://img.shields.io/badge/MCU-Renesas%20RH850%2FF1L%20(64KB%20DFlash)-0284C7?style=for-the-badge)](#给编程器的-64-kb-dataflash-规则)
[![Free](https://img.shields.io/badge/Status-FREE-D97706?style=for-the-badge)](#用途与使用条款)
[![License PolyForm NC](https://img.shields.io/badge/License-PolyForm%20Noncommercial-16A34A?style=for-the-badge)](#许可)

[![Website](https://img.shields.io/badge/Web-vwhacking.antonperk.com-181717?style=flat-square&logo=googlechrome&logoColor=00D8FF)](https://vwhacking.antonperk.com)
[![Drive2](https://img.shields.io/badge/Drive2-PerkTheFox-E31E24?style=flat-square&logo=rss&logoColor=white)](https://www.drive2.ru/users/perkthefox/)
[![Telegram](https://img.shields.io/badge/Telegram-%40perkthefox-26A5E4?style=flat-square&logo=telegram&logoColor=white)](https://t.me/perkthefox)

**Made by PerkTheFox** • **[🇷🇺 俄文 (`README.md`)](README.md) | [🇬🇧 English (`README.en.md`)](README.en.md) | 中文** • **[📚 深入技术文档 (`docs/`)](docs/README.md)**

</div>

<p align="center">
  <img src="assets/screenshots/en_features.png" alt="ContiTool：已打开的控制单元，用网关自己的应答做 SWaP 功能激活" width="100%">
</p>

---

## 用途与使用条款

**ContiTool** 是给汽车电工、诊断技师和 **VAG MQB** 车主使用的台架工具，带图形界面（**Qt 6 / PySide6**）和命令行（**CLI**）。它在台架上维护 **Continental J533 网关（`3Q0 907 530 xx`，Renesas `RH850/F1L`）**：经 CAN 做完整闪存备份、维修或更换网关、适配加装控制单元（**Component Protection**），以及管理 **SWaP / FeC** 证书。

只支持这一款。`5Q0 907 530` 和 Lear 的 `3Q0 907 530` 是 **NXP PowerPC（`MPC5607B` / `MPC5748G` VLE）**，没有 `Uflash`、`FACI` 和 `ICUS0`。即使零件号相同（Lear 的 `3Q0 907 530 AA`），或者控制单元自报为 `EV_GatewConti`（Continental 的 `5Q0`），也是如此。检查链路时（`F191` / `F187` / `F1A3` / `F19E` / `F17C`）会识别它们，并在发出引导程序命令之前停止。

- **不要使用本程序**，如果你并不清楚自己为什么需要它，不会使用 ODIS 或 VCTool，或者对适配器、接线或供电有任何疑虑。廉价适配器不视为安全，即使程序能和它们配合。2 美元的适配器把变砖概率提高 99.9%。
- **不要把它接到能正常行驶的车上。** 把网关拆下来，在台架上用稳压电源工作。在车上，网关连接所有控制单元：它停在引导程序里，或一次写入中断，各控制单元就互相看不见——车可能无法启动，也无法行驶。长时间写入时车上电压会下跌，写入过程中任何跌落或掉电都会变砖。如果仍然接到汽车上，风险由你自己承担：作者对损坏的控制单元不负任何责任。不要为此发私信——请开一个 [GitHub Issue](https://github.com/perkthefox/mqb_contitool/issues) 并等待回复。
- **免费的社区工具。** 程序免费，并且始终发布在 [GitHub](https://github.com/perkthefox/mqb_contitool/releases)；[许可](#许可)禁止出售。如果有人把它卖给你，你被骗了。
- 软件按 **“原样”（`AS IS`）** 提供，没有任何保证，只用于在自有硬件上做合法的台架维护和工程研究。作者（`PerkTheFox`）对任何直接或间接损失不承担责任。**任何写入之前，务必保存并核对全部存储区的完整备份（`Cflash.bin` `1.5 MB`、`Uflash.bin` `32 KB`、`Dflash.bin` `64 KB`）。**

---

## 快速开始

### 方式 1 — 独立程序（推荐）

从 **Releases** 下载压缩包：

- **Windows**：解压 `ContiTool-v2.1.1-windows-amd64.zip`，运行 **`ContiTool.exe`**。
- **macOS**：打开 `ContiTool-v2.1.1-macos-arm64.dmg`（或 `.zip`），运行 **`ContiTool.app`**。
- **Linux**：解压 `ContiTool-v2.1.1-linux-x86_64.tar.gz`，运行 **`ContiTool/ContiTool`**。

不需要安装 Python，也不需要安装第三方库。

### 方式 2 — 从源码运行（`Python 3.12+`）

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 启动图形界面。界面语言也可在标题栏切换：
python3 conti_cp_tool.py

# 启动时即为中文：
python3 conti_cp_tool.py -l cn
```

自行打包 `.exe` / `.app`：`pip install -r requirements-dev.txt && python3 scripts/build_release.py`（结果在 `dist/release/`）。

标题栏可以一键切换 **Русский ⇄ 中文 ⇄ English**。命令行用 `-l ru` / `-l cn` / `-l en`。不带参数运行会打开图形界面；传入任一子命令则进入命令行，并显示实时进度。

---

## 使用步骤

图形界面围绕一块网关。顺序是：

1. 按下面的针脚接线，接上适配器。
2. 读取控制单元。ContiTool 保存完整存储器副本并打开它。也可以不连控制单元，从已有的转储文件夹载入。
3. 在打开的这一块上修改。改动写进副本，原始转储保持不动。
4. 点 **「写入控制单元」**，经 Diagnosis CAN 刷写全部已修改的存储区。写入过程中不要掉电。

三个存储区（含引导块的 **CodeFlash**、**DataFlash** `64 KB`、**Uflash** `32 KB`）都经 CAN 读写，不需要外接编程器。窗口底部的日志默认是简短摘要（操作、步骤和结果）；「详细」显示带地址、UDS 和 CAN 的完整技术日志。每一次操作的状态栏都会显示当前步骤、进度 `%`、传输量和速度（`KB/s`）、已用时间和剩余时间。启动时会检查 GitHub 上是否有新版本。

### 1. 台架接线（J533 `T20`）

经 **Diagnosis CAN（`500 kbit/s`）** 把 5 根线接到网关的 20 针接插件：

| J533 `T20` 针脚 | 电路 | 作用 |
| :---: | :--- | :--- |
| **Pin 1** | `KL30 (+12V)` | 常电 `+12 V`（稳压电源 `12.5–13.8 V`） |
| **Pin 14** | `KL15 (+12V)` | 点火 `+12 V`（台架上与 `Pin 1` 短接） |
| **Pin 11** | `KL31 (GND)` | 电源负极与 CAN 适配器的 `GND` |
| **Pin 19** | `Diag CAN-H` | 诊断总线 `CAN High`（`500 kbit/s`） |
| **Pin 9** | `Diag CAN-L` | 诊断总线 `CAN Low`（`500 kbit/s`） |

> [!IMPORTANT]
> **必须在 `Pin 19`（`CAN-H`）和 `Pin 9`（`CAN-L`）之间接 `120 Ω` 电阻**（或打开适配器上的 `120 Ω` 终端）。`J533` 的诊断线上没有内部终端电阻，不加的话总线会进入 `Bus-Off`。`VAS 6154` / `VNCI` 和 `J2534` 适配器自己做总线终端。

程序会自动发现已连接的适配器：`CANable` / `SLCAN`、`SocketCAN`、`PCAN`、`Vector`、`Kvaser`；在 Windows 上还有 `J2534 PassThru`（Tactrix、Mongoose 等），以及经 ODIS 的 D-PDU 驱动、用硬件 `ISO-TP` 做刷写的 `VAS 6154` / `VNCI 6154A`。用「检查链路」确认。操作进行时不会再打开第二条到适配器的链路。

读取存储器需要直连 USB 的适配器：串口 SLCAN 克隆（CH340 等）会丢帧。Windows 版本附带已验证的 D-PDU 驱动 `27.2`（`dpdu/VW_PDUAPI_27.2`）。`30` 及更新的版本需要单独确认：UDS 刷写中途适配器会挂起，而且连接时驱动会把 VCI 刷成它自己的版本。ContiTool 工作时，ODIS 和 VCTool 必须保持关闭。

### 给编程器的 `64 KB DataFlash` 规则

> [!WARNING]
> `3Q0 907 530 xx` 网关的处理器外壳上刻的是 `R7F7010343AFP`，但里面实际是子系列 **`R7F7010543AFP / R7F7010563AFP`，带完整的 `64 KB` DataFlash（`65,536` 字节）**，而且 **全部 12 个 `CP` 库和 `SWaP` 密钥都在后一半（`0xC000..0xFFFF`）**。
> - **不要选择** `32 KB` 的 `R7F7010343` 配置——它会截掉所有密钥。
> - 用第三方工具导入或导出转储时，**始终选择** 控制单元预设 `3Q0907530`，或芯片配置 **`R7F7010543` / `R7F7010563`（`64 KB Dflash`）**。用 ContiTool 经 CAN 读取和写入时，全部 `64 KB` 会自动处理。

### 2. 读取控制单元

量产网关的处理器外部接口是锁住的（`Security Lock`），但进入引导程序 `Uflash.bin`（`ProgrammingSession 10 02`）是原厂支持的。在 `Uflash` 里，工具分两步把 `Renesas FCL` 闪存驱动描述符（`0xFEDE0C68`）的指针改到内置原厂 **`CAN RAM-Loader` 第二阶段的入口（`0x0100120E`，流 `0x6F0 / 0x6F1`）**。

在 `RAM-Loader` 里，带看门狗喂狗的批量桩 `FED_READER` 读出 `Cflash`（`1.5 MB`，约 `~61 s`）和 `Uflash`（`32 KB`）。桩 `DFLASH_READER_STUB` 经诊断用的 `FACI Blank Check` 确定性地读出 `DataFlash`（`64 KB`），已擦除单元不会带上噪声。同一次读取还包括 **`Eeprom.bin`（`8 KB`，外部 SPI EEPROM `ST M95640`，只读）** 和 **`Opbt.bin`（`36 B`，`OPBT0..OPBT8`、`Extra Area @ 0xFF300050` 的 `IDCODE` 和 `CHIP ID @ 0xFFCD00E0`，只读）**，并做 `SHA-256` 校验。也可以读取任意物理地址范围（闪存、`Local RAM`、寄存器），命令行是 `can read-mem`。

每次读取和写入都按具体网关放在 `contitool_runs/<零件号>_<FAZIT>/`：

- `dumps/base_read` — 这块控制单元的第一份完整转储
- `*_flashed` 与 `manifest.json` — 写入之后存储器里的内容
- `writes/` — 操作日志和写入前备份

**「导出备份…」** 把读到的转储复制到选定文件夹。第一次读取时如果通信中断、网关不再应答：在台架上断开 `+12 V` 几秒再接上。

### 3. 在界面里修改

网关只打开一次。之后整个界面都描述这一块：零件号、校验和、`VIN`、`VCRN`，以及每一项功能各自一行的当前状态。左侧是功能及其状态，右侧是所选功能的页面：它做什么、分步操作，以及已启用功能的名称列表。底部面板显示每份转储的状态（`CodeFlash`、`DataFlash`、`Uflash`）。

下面是英文界面，标题栏可以切换为中文。

| | |
|:---:|:---:|
| <img src="assets/screenshots/en_zdc.png" alt="参数化" width="100%"><br>**参数化** — 驾驶模式、MKE、启停、发电机 | <img src="assets/screenshots/en_fpa.png" alt="FPA 编辑器" width="100%"><br>**驾驶模式与按键** — FPA 编辑器 |
| <img src="assets/screenshots/en_dtc.png" alt="DTC 存储器" width="100%"><br>**DTC 存储器** — ODIS 代码和通俗说明 | <img src="assets/screenshots/en_terminal.png" alt="CAN 终端" width="100%"><br>**CAN 终端** — ISO-TP 上的 UDS，应答已解码 |
| <img src="assets/screenshots/en_connection.png" alt="连接控制单元" width="100%"><br>**连接** — 已发现的适配器和 T20 接线图 | <img src="assets/screenshots/en_restore.png" alt="写回备份" width="100%"><br>**写回备份** — 只能写入同一块控制单元（FAZIT / VCRN） |

#### 组件保护（`KSCHUTZ`）

全部 **12 个 VAG 从控制单元库（`#1..#12`）** 都会显示状态。程序拒绝误写入全零密钥 `00..00` 或 `SHE M1` 头（`00..00E5`）。

`CodeFlash` 里 38 字节的混合跳板：车上所有原厂控制单元（`SHE M1..M3` 和主密钥 `GFA`）继续按原厂方式工作，选定的加装控制单元则使用 16 字节明文 `IKA` 密钥。原厂控制单元把密钥以 64 字节 `SHE M1..M3` 容器放在 `DataFlash` 里，由硬件模块 `ICUS0` 展开（`CMD_LOAD_KEY = 0x40`）。跳板在 `0x0016FF80`，检查 `M2/M3` 缓冲区的尾部：原厂容器和主密钥 `GFA`（`0xDA00`）走原厂模式 `0x40`；尾部为零、存放 16 字节明文 `IKA` 密钥的库则自动选用 `CMD_LOAD_PLAIN_KEY = 0x10`。

向以前为空的库（`47`、`57`、`3C`、`CF`、`3D`、`A5`、`8C` 等）写入时，自动绕过外部 `ST M95640 SPI EEPROM` 的位掩码，不用焊下 `95640`。

**被绑定控制单元的 `K3`（`IKA`）密钥必须事先已经拿到。** 明文 `K3` 从不出现在 CAN 流量或 `ODIS` 日志里，要事先从那块加装或供体从控制单元自己的存储器转储里读出（`5F`、`17`、`13`、`47`、`A5` 等）。

| 库 | 控制单元 | MQB 模块 | `Dflash` 偏移 | `NvM` | `95640` 掩码 | UDS ID | CP CAN TX / RX |
| :---: | :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| `#1` | **`17`** | 仪表 / 防盗（`J285`） | `0xC000` / `0xC080` | `0x60` | `0x0001` | `714 / 77E` | `17FC0114 / 17FE0114` |
| `#2` | **`09`** | 中央电器 `BCM`（`J519`） | `0xC100` / `0xC180` | `0x61` | `0x0002` | `70E / 778` | `17FC010E / 17FE010E` |
| `#3` | **`13`** | 自适应巡航雷达 `ACC`（`J428`） | `0xC200` / `0xC280` | `0x62` | `0x0004` | `757 / 7C1` | `17FC0157 / 17FE0157` |
| `#4` | **`15`** | 安全气囊 `Airbag`（`J234`） | `0xC300` / `0xC380` | `0x63` | `0x0008` | `715 / 77F` | `17FC0115 / 17FE0115` |
| `#5` | **`47`** | 数字音响功放（`J525`） | `0xC400` / `0xC480` | `0x64` | `0x0010` | `76F / 7D9` | `17FC016F / 17FE016F` |
| `#6` | **`57`** | 电视调谐器（`R78`） | `0xC500` / `0xC580` | `0x65` | `0x0020` | `76D / 7D7` | `17FC016D / 17FE016D` |
| `#7` | **`5F`** | 信息娱乐 `MIB1 / MIB2 / MIB3`（`J794`） | `0xC600` / `0xC680` | `0x66` | `0x0040` | `773 / 7DD` | `17FC0173 / 17FE0173` |
| `#8` | **`3C`** | 变道辅助 `Master`（`J769`） | `0xC700` / `0xC780` | `0x67` | `0x0080` | `74E / 7B8` | `17FC014E / 17FE014E` |
| `#9` | **`CF`** | 变道辅助 `Slave`（`J770`） | `0xC800` / `0xC880` | `0x68` | `0x0100` | `78A / 7F4` | `17FC018A / 17FE018A` |
| `#10` | **`3D`** | 特殊功能（`J608`） | `0xC900` / `0xC980` | `0x69` | `0x0200` | `72C / 796` | `17FC012C / 17FE012C` |
| `#11` | **`A5`** | 前向辅助摄像头（`R242`） | `0xCA00` / `0xCA80` | `0x6A` | `0x0400` | `74F / 7B9` | `17FC014F / 17FE014F` |
| `#12` | **`8C`** | 混动 / 电动高压电池管理（`J840`） | `0xCB00` / `0xCB80` | `0x6B` | `0x0800` | `77B / 7E5` | `17FC017B / 17FE017B` |
| `Mst` | **`19`** | 网关自己的主密钥 `GFA`（`Master`） | `0xDA00` / `0xDA80` | `0x7B` | — | `710 / 77A` | *不要改动！* |

#### 工程模式

两项都可以完全恢复为原厂。

- `CodeFlash`：打开 `Feature 0x80/0x81/0x83`，去掉在线服务器 `ASAM CCP v2.1`（`0x1BFC8600 / 0x1BFC8601`）的地址过滤，并允许进入原厂 `CAN RAM-Loader`。
- `Uflash`：4 字节补丁 `+0x342A`，使引导程序接受任何 `App CRC-16` 正确的固件和 `.odx`，不再要求原厂 `RSA-1024` 签名。

#### SWaP、证书与参数化

- 生成 `RSA-1024 (e = 3)` 密钥对，导出 `.json` 以及 OpenSSL `.private.pem` / `.public.pem`。
- 同步替换 `CodeFlash.bin` 和 `DataFlash.bin` 镜像缓存里的公钥模数（`NvM 0x7C @ 0xDB04`，重算 `CRC-32 @ 0xDCE4`，并保留原有的 5 字节 `VCRN @ 0xDC0C`）。
- 签发 171 字节（`0xAB`）的 **VAG SWaP `FSC` v2** 激活证书（`RIPEMD-160 + RSA-1024`，包括 `FPA Driving Profile 10000100`、`MKE 10000300` 等），用于经 OBD 上传（`2E 3C 01` + `31 01 C0 01`），以及为 `.odx` 做 `<FW-SIGNATURE>`（`SHA-1 + RSA-1024`）签名。
- 「SWaP/FEC 激活」页读取 `22 3C 00`：哪些功能已接受，哪些被拒绝以及原因。
- **「通过 CAN 写入数据集…」** 检查当前的 `SWaP` 功能（`22 3C 00`）和编码（`22 06 00`），必要时直接在网关的 `DataFlash` 里打开缺少的 `SWaP` 功能，经 UDS 上传 `ZDC` 数据集，并对齐 `0x0600` 编码位。

#### 故障码与 CAN 终端

`19 02` 读到的代码会显示 ODIS 代码（`U023500`、`B189CF0` 等）和说明。界面为中文时显示中文，覆盖整份 MQB 网关故障码集（770 条）。当前故障、已存储故障，以及清除后尚未再检测的代码是分开的——最后一类不是故障。

**CAN 终端**可以发送自己的 CAN 帧（11/29 位）或经 ISO-TP 的 UDS 请求。应答会完整拼合，`7F xx 78` 会处理，否定应答码会解码。带实时流量表、按 ID 过滤、暂停、复制、保存到文件，以及命令历史。

### 4. 写入控制单元

**「写入控制单元」** 经 Diagnosis CAN 刷写**全部**已修改的存储区。修补后的 `CodeFlash.bin` 和更新后的 `DataFlash.bin`（内有 `IKA` 密钥或 `SWaP RSA` 公钥模数）都走这一条路。命令行对应 `can write-dflash`、`can write-cflash`，或用 `can turnkey` 从备份一直做到清除 `DTC`。

写入任一存储区时，RAM 里会装上自包含的原生 `RH850 FACI` 驱动，负责喂狗 `WDTA0 / WDTA1`，并从 `Cflash + 0xAB00` 自动装入芯片的 128 位 `SELFID`。

经 CAN 写入 `CodeFlash` 之前，如果网关仍是原厂引导程序，ContiTool 会经 `FACI` 自动激活工程引导程序，在 `F15A` 写入全零测试仪序列号（这样以后读取不会无应答），并把改过的 `CodeFlash` 引导块（`0x0000..0xBFFF`，例如自定义 `FBL RSA` 密钥、块 `4`）和 `DataFlash`（`64 KB`）经 RAM 里的 `FACI` 驱动直接写入。

- **`DataFlash`（`64 KB`，`0xFF200000..0xFF20FFFF`）**：按 64 字节块差分刷写（`FENTRYR = 0xAA80`），4 字节按字写入，为 `Renesas FDL` 驱动保留硬件 `ECC`，保护系统区 `ICUSB`（`0xF800..0xFFFF`）。对 `ZDC < 0x3040` 做完整 16 字编程以免 `DTC 000401`，自动对齐编码 `0x0600`，并做全部 `64 KB` 的回读校验。
- **`Uflash`（`32 KB`）**：在 RAM 里整包刷写，带 4 字节补丁 `+0x342A`、写入前备份、全部 `32 KB` 回读校验，以及在线 `RSA` 探测。
- **`CodeFlash`（`1.5 MB`）**：引导扇区 `0x00000000..0x0000BFFF`（含 `Sector 5`，`FBL RSA` 密钥在 `0x0000A2F7`，并自动保留 `0x0000AB00` 处芯片原有的 128 位 `SELFID`）经 `FACI` 写入。应用程序区 `FD_0DATA` 按原厂 `UDS` 刷写并校验 `App CRC-16/MODBUS`（`0x0000C21C`），也可以整片用 `--raw-faci`。随后逐字节校验全部 `1.5 MB`，检查通信（`10 03` / `3E 00`），并读取或清除 `DTC`。

### 5. 写回备份，以及写入中断之后

**「写入备份…」** 用来把备份写回控制单元，包括一次刷写中断后网关**卡在 `FBL` 引导程序**里。你指定备份文件后，ContiTool 先经 UDS 核对 `FAZIT` / `VCRN`，在发出第一条写入命令之前拒绝另一块控制单元的备份。

网关已经停在 `FBL` 时，程序不会进入 `RAM-Loader`，而是用 `22 F1 7C`（`FAZIT`）核对转储归属，然后直接刷写应用程序。如果引导程序回答 `7F 27 37`（保护延时），断开 `+12 V` `10` 秒，重新上电后它自己继续写入。

**刷写之后读不出来（进入 `RAM-Loader` 的阶段 1 无应答）。** 阶段 1 填充里的最后一份 `F15B`，会把测试仪序列号的第 `2..5` 字节放到引导程序的服务单元 `0xFEDE0C62`（“不要应答”标志）上。`v2.0.1d` 及更早的 ContiTool（`01 02 03 04 05 06` → `0x03`）和 ODIS（它自己的非零序列号 → 例如 `0xC8`）都在那里留下了非零字节，之后阶段 1 就不再应答。从 `v2.0.1e` 起，ContiTool 始终写入全零序列号。在 `v2.0.2` 里，遇到这种无应答会在发送密钥之前停下（以免触发 `7F 27 37`），并自己提议修复：用全零序列号，把这块控制单元的应用程序按 UDS 再刷写一次。用 ODIS 再刷只有把指纹设成全零才行；用它平时的非零指纹，ODIS 自己就会造成同样的问题。

**程序要求写入备份来把指纹清零，但这块控制单元没有备份。** 改刷这块网关对应的原厂 FRF：可以用 VCTool 或 ODIS，也可以用 ContiTool 自己（「文件 → 刷写 ODIS FRF / ODX…」，或修复窗口里的「FRF / ODX 文件…」；`.frf` 和普通 `.odx` 都可以）。ContiTool 始终写入全零指纹。如果用 ODIS 或 VCTool 配原厂适配器刷写，先确认它们的设置里指纹是全零（进口商代码、维修站代码和测试仪编号都是 0）；否则它们会写入自己的非零序列号，`RAM-Loader` 入口仍然打不开。

---

## 命令行

```bash
# 全部命令的帮助，以及检查转储：
python3 conti_cp_tool.py -l cn --help
python3 conti_cp_tool.py -l cn inspect --cflash Cflash.bin --dflash Dflash.bin --uflash Uflash.bin

# 一条命令完成 CP 绑定（混合跳板 + 空库自动绕过 95640 + 写入 IKA）：
python3 conti_cp_tool.py -l cn bind-cp \
  --cflash-in Cflash.bin --dflash-in Dflash.bin \
  --cflash-out Cflash_cp.bin --dflash-out Dflash_cp.bin \
  --set 5F=A1B2C3D4E5F60718293A4B5C6D7E8F90

# 打开工程模式，并签发自己的 SWaP FSC 证书（FPA 10000100）：
python3 conti_cp_tool.py -l cn patch-engineering --cflash-in Cflash.bin --cflash-out Cflash_eng.bin --uflash-in Uflash.bin --uflash-out Uflash_eng.bin
python3 conti_cp_tool.py -l cn set-rsa-key --generate-key swap_key.json --cflash-in Cflash.bin --cflash-out Cflash_swap.bin --dflash-in Dflash.bin --dflash-out Dflash_swap.bin --target swap
python3 conti_cp_tool.py -l cn sign-fsc --key swap_key.json --dflash Dflash_swap.bin --fec 10000100 -o fpa_10000100.fsc

# Diagnosis CAN 上的操作（自动查找适配器、读写全部存储区，以及一条命令走完全程）：
python3 conti_cp_tool.py -l cn can ports
python3 conti_cp_tool.py -l cn can backup --port /dev/ttyACM0
python3 conti_cp_tool.py -l cn can write-dflash --port /dev/ttyACM0 --dflash Dflash_cp.bin --yes
python3 conti_cp_tool.py -l cn can write-cflash --port /dev/ttyACM0 --cflash Cflash_cp.bin --yes
python3 conti_cp_tool.py -l cn can read-mem --port /dev/ttyACM0 --address 0xFF20C000 --length 0x1000 --out-file cp_banks.bin
python3 conti_cp_tool.py -l cn can turnkey --port COM4 --set 5F=A1B2C3D4E5F60718293A4B5C6D7E8F90 --clear-dtc --yes
```

`can turnkey` 的顺序是：完整备份 → 解锁 `Uflash` → 把 `CP` 密钥写入 `DataFlash` → 修补并刷写 `CodeFlash` → 检查并清除 `DTC`。

---

## 常见问题

**驱动是支持的，但 VNCI 连不上。**
重新插上适配器，或连续按几次「检查链路」。连接时 D-PDU 驱动会自己把适配器刷成它的版本（大约 30 秒），ContiTool 会把这当成 CAN 通信错误。还不行就重启电脑。

**用 VAS 6154 / VNCI 需要 ODIS 吗？**
不需要。D-PDU 驱动 27.2 随 ContiTool 提供（程序旁边的 `dpdu/` 文件夹）。系统里只需要适配器自己的 USB 驱动，也就是 **VW D-PDU API** 包里的 VAS 6154 附加组件。

**电脑上有好几个 D-PDU 驱动，程序用哪一个？**
找到的每一个都会在「控制单元连接」窗口里单独占一行，并显示版本。默认选用随 ContiTool 提供的驱动 27.2，也可以选其他驱动，选择会被记住。30 及更新的驱动目前不稳定，使用它们需要单独勾选确认。

**驱动刷写适配器——这正常吗？**
正常。连接时 D-PDU 驱动会自己把对应版本的固件写入 VAS 6154 / VNCI（大约 30 秒）。等它完成，不要拔掉适配器。下次连接时 ODIS 也会把自己的版本写进适配器。

**“适配器不提供原始 CAN 通道”是什么意思？**
ContiTool 经引脚 6/14 上的 RawMode 读取存储器。一部分适配器不提供它：其他厂商的 J2534 驱动，以及一部分 VAS 6154 / VNCI（包括正品）——拒绝来自适配器本身，换哪个驱动都一样。这时程序会尝试后备方式（按固定标识符建立 ODIS 风格的链路），并用一次请求自行验证。如果它也不应答，这个适配器不能用；可以换另一个 D-PDU 驱动，否则换适配器。

**需要另一个版本的驱动。**
把已安装驱动的文件夹复制到 ContiTool 旁边的 `dpdu/` 里，和已有的 `VW_PDUAPI_27.2` 放在一起——程序会自己找到。不需要写注册表，也不需要管理员权限；必须是 64 位版本。

---

## 深入技术文档

**[`docs/`](docs/README.md)** 里是各机制的逐字节说明。目前只有俄文和英文：

- **[`docs/can-read-write.md`](docs/can-read-write.md)** · **[`docs/can-read-write.en.md`](docs/can-read-write.en.md)** — 进入 `CAN RAM-Loader`、读取全部存储区，以及经 `FACI` 写入 `Uflash`、`DataFlash` 和 `CodeFlash`。
- **[`docs/component-protection.md`](docs/component-protection.md)** · **[`docs/component-protection.en.md`](docs/component-protection.en.md)** — `KSCHUTZ` 与 `ICUS0`、混合跳板、`95640` 掩码和 `DataFlash` 地图。
- **[`docs/engineering-and-swap.md`](docs/engineering-and-swap.md)** · **[`docs/engineering-and-swap.en.md`](docs/engineering-and-swap.en.md)** — 工程模式、`ZDC` 参数化，以及 `RSA-1024`、`SWaP FSC v2` 和 `ODX` 签名。

## 参与与反馈

- **程序错误或操作失败** — 出错后点 **「创建报告…」**（或「帮助 → 报告问题…」）。程序会把程序日志、本次操作日志和 D-PDU 驱动日志打成压缩包（默认不含 `*.bin` 存储器转储，需要时可以勾选单独附上），并打开已经填好正文的新 [GitHub Issue](https://github.com/perkthefox/mqb_contitool/issues)——把压缩包拖进去即可。也可以用「问题」表单开一个 [Issue](https://github.com/perkthefox/mqb_contitool/issues/new/choose)。不要给作者发私信。
- **提问**（怎么接线、用哪个适配器）— 写在 [Discussions](https://github.com/perkthefox/mqb_contitool/discussions)。
- **代码改动** — 见 [`CONTRIBUTING.md`](CONTRIBUTING.md)。ContiTool 自身的漏洞 — [`SECURITY.md`](SECURITY.md)。

## 许可

ContiTool © 2026 PerkTheFox 以 **[PolyForm Noncommercial 1.0.0 及附加条款](LICENSE)** 发布。简要说明如下（法律上只以 `LICENSE` 正文为准）：

- **代码公开** — 可以阅读、研究和修改；
- **免费**用于个人和非商业用途，也**可用于收费维修和诊断**：维修站可以用它给客户的车做工作；
- **禁止出售** — 不能卖程序本身、副本、对它的访问权限，也不能把它放进付费套件里卖；
- **修改后的版本**只能在同样条件下公开源代码再分发，并保留作者声明（`Required Notice`）。

发行包里的第三方组件（Qt / PySide6 和 python-can 使用 LGPL-3.0，以及其他组件）列在 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

---

<div align="center">

**Made by PerkTheFox**  
[vwhacking.antonperk.com](https://vwhacking.antonperk.com) • [Drive2: perkthefox](https://www.drive2.ru/users/perkthefox/) • [Telegram: @perkthefox](https://t.me/perkthefox)

</div>
