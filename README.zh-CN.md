用于 VMware Workstation 的 macOS Unlocker V3.0
==============================================

***
### <div align="center">请在此处阅读：</div>

Windows用户：请从“版本发布”页面下载工具，该版本已预装了Python环境，可以避免因缺少Python而导致的病毒警告或其他问题。

Linux用户：Linux版本不包含预装的Python环境，请确保您已安装Python 3.0及以上版本。如果出现“不支持Python”之类的错误（但您已安装了Python），请尝试使用以下命令运行脚本：`PYVERSION=python3.7`（前提是您已安装了Python 3.7，否则请尝试使用python3或其他版本）。   

***
<table align="center"><tr><td align="center" width="9999">

| 重要的：
| ---
| 在使用新版本Unlocker之前，务必先卸载旧版本。
| 如果未能完成此步骤，VMware可能无法正常运行。

</td></tr></table>

***

### 1. 介绍
-------

Unlocker 3 适用于 VMware Workstation 11-25H2 以及 Player 7-25H2。

如果您正使用早期版本的 VMWare，请继续使用 Unlocker 1。

Unlocker 3 已对以下情况进行了测试：

* 在 Windows 或 Linux 上的 Workstation 11/12/14/15/16/17/25H2
* 在 Windows 或 Linux 上的 Workstation Player 7/12/14/15/16/17/25H2

根据所修补的产品，本代码会作出以下修改：

* 修补 vmware-vmx 及其相关组件，以允许 Mac OS 启动。
* 修补 vmwarebase .dll 或 .so，以允许创建虚拟机过程中选择 Apple 作为客户机操作系统。
* 下载一份最新的用于 Mac OS 的 VMWare Tools 副本。

请注意，并非所有产品都能通过安装工具菜单项识别 darwin.iso 文件。
例如，在Workstation 11和Player 7中，您需要手动挂载darwin.iso文件。

无论何时都请确保 VMware 未在运行且所有后台的客户机都已关闭。

本软件的代码是用 Python 编写的。

### 2. 先决条件
-----------

该程序需要Python 3.0或更高版本才能运行。大多数Linux发行版都预装了兼容的Python解释器，因此无需额外安装任何软件即可运行。

Windows Unlocker使用PyInstaller将Python脚本打包，因此无需安装Python即可运行。

### 3. 限制
-------

如果您使用的是用于 Windows 的 VMware Player 或 Workstation，您可能会得到一个核心转储文件。

最新的 Linux 版本 VMWare 则不会出现此问题。

<table align="center"><tr><td align="center" width="9999">
   
| 重要提醒：
| ---
| 如果您创建一个新的虚拟机，VMware 可能会停止工作并创建一个核心转储文件。
| 有两种方法可以解决这个问题：
| 1. 将虚拟机的硬件兼容性设置为 Workstation 10 - 这不会影响性能。
| 2. 编辑 VMX 文件并添加：<br/>smc.version = "0"

</td></tr></table>

### 4. Windows
----------
在 Windows 下，您可以通过以管理员身份运行 cmd.exe 再在其中运行脚本，或在资源管理
器里右击脚本并选择“以管理员身份运行”。

- win-install.cmd   - 修补 VMware
- win-uninstall.cmd - 还原 VMware
- win-update-tools.cmd - 检索最新的用于 Mac OS 的 VMWare Tools

### 5. Linux
--------
在 Linux 下，您需要是 root 用户，或使用 sudo 运行脚本。

您可能需要通过对下面三个脚本中的前两个运行 chmod +x 来确保它们具有执行权限。

- lnx-install.sh   - 修补 VMware
- lnx-uninstall.sh - 还原 VMware
- lnx-update-tools.sh - 检索最新的用于 Mac OS 的 VMWare Tools
   
### 6. 致谢
-------

感谢 Zenith432 最初构建了 C++ 版本的 Unlocker，还要感谢 Mac Son of Knife（MSoK）
的所有测试与支持。

同样感谢 Sam B 找到了针对 ESXi 6 的解决方案，并帮我进行了专业的调试。Sam 还编写了
修补 ESXi ELF 文件的代码，并编辑了 Unlocker 的代码使其能在 ESXi 6.5 的环境下运行
在 Python 3 上。


更新历史
--------

| 日期 | 发布 | 描述
| --- | --- | ---
| 2018/09/27 | 3.0.0 | 首个发行版
| 2018/10/02 | 3.0.1 | 修正了 gettools.py 使其能在 Python 3 环境下正常工作且能正确下 载 darwinPre15.iso
| 2018/10/10 | 3.0.2 | 修正了带有 Windows 可执行程序的杀毒软件对本程序的误报<br/>- 允许 Python 2 和 3 从 Bash 脚本运行 Python 代码
| 2019/10/24 | 3.0.3 | 修復了適用於VMware Workstation 15.5的解鎖程序和gettools
| 2021/11/05 | 3.0.4 | 用于VMware Workstation 16.2.0 build-18760230的固定gettools并为每个OS +添加分隔备份文件夹
| 15/12/2022 | 3.0.5 | 的固定 gettools 用于 VMware Workstation 17.0.0 Build-20800274
| 06/02/2023 | 3.0.6 | 的固定 gettools 用于 VMware Workstation 17.0.1 Build-21139696
| 27/05/2024 | 3.0.7 | 修复了 gettools 的 HTTP 错误 403：禁止
| 11/11/2024 | 3.0.8 | 修復了達爾文找不到文件的 gettools
| 24/03/2025 | 3.0.9 | 修复了 gettools 的 IndexError：列表索引超出范围
| 28/03/2025 | 3.1.0 | 已修复错误：\VMware\VMware 此时是意外的。
| 27/09/2025 | 3.1.1 | 移除对 Python 2 的支持。
| 29/10/2025 | 3.1.2 | 添加 CI 工作流和压缩可执行文件。
| 16/02/2026 | 3.1.3 | 防止工具被多次安装。

(c) 2011-2018 Dave Parsons
