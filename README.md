# imx6ull-bms-update

## 工程简介

这个仓库用于维护 i.MX6ULL BMS 板子的 Linux 启动文件和一键同步脚本，主要包含：

- `zImage`：Linux 内核镜像  
- `imx6ull-bms-nand.dtb`：设备树文件  
- `rootfs.tar.bz2`：根文件系统打包文件  
- `plink.exe` / `pscp.exe`：Windows 下的 SSH / SCP 工具  
- `update_from_ubuntu.ps1` / `update_from_ubuntu_full.ps1`：从 Ubuntu 编译环境同步文件到本机 mfgtool 目录的 PowerShell 脚本  
- `update_from_ubuntu.bat` / `update_from_ubuntu_full.bat`：方便在 Windows 下双击调用 PowerShell 的批处理脚本  

典型场景是：在 Ubuntu 上编译好内核、dtb、rootfs 后，通过脚本一键同步到 Windows 下的 mfgtool 工程目录，然后用 mfgtool 给 BMS 板子刷机。

## 目录与文件说明

- `zImage`  
  - 从 Ubuntu 编译得到的 Linux 内核镜像。

- `imx6ull-bms-nand.dtb`  
  - 对应 BMS 板硬件的设备树文件。

- `rootfs.tar.bz2`  
  - 由 Ubuntu 上的 `/home/xixing/linux/nfs/buildroot/rootfs` 目录重新打包得到的根文件系统。

- `plink.exe` / `pscp.exe`  
  - PuTTY 套件中的命令行工具，用于在 Windows 上通过 SSH 登录远程 Ubuntu（`plink`），以及通过 SCP 拷贝文件（`pscp`）。
  - 脚本会假定它们和脚本放在同一个目录下。

- `update_from_ubuntu.ps1`  
  - 标题：`Ubuntu BMS 文件一键同步工具`。  
  - 功能概览：  
    1. 使用 `plink` 登录到 Ubuntu，进入 `/home/xixing/linux/nfs/buildroot/rootfs`，删除旧的 `rootfs.tar.bz2`，重新打包当前 rootfs。  
    2. 确保本地 mfgtool 目标目录存在：  
       - `F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\boot`  
       - `F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\filesystem`  
    3. 使用 `pscp` 将远程 `/home/xixing/linux/tftpboot/zImage` 拷贝到 `boot` 目录。  
    4. 使用 `pscp` 将远程 `/home/xixing/linux/tftpboot/imx6ull-bms-nand.dtb` 拷贝到 `boot` 目录。  

- `update_from_ubuntu_full.ps1`  
  - 功能与上面类似，也是全量同步脚本（内核 + dtb + rootfs），只是输出提示略有不同。  
  - 同样使用 `plink` 和 `pscp`，从远程 Ubuntu 重新打包 rootfs 并同步到本地 mfgtool 目录。

- `update_from_ubuntu.bat` / `update_from_ubuntu_full.bat`  
  - Windows 批处理封装：  
    - 切换到当前脚本所在目录；  
    - 调用对应的 PowerShell 脚本（`update_from_ubuntu.ps1` 或 `update_from_ubuntu_full.ps1`）。  
  - 方便在资源管理器下直接双击运行。

## 使用方法（快速上手）

### 1. 前提条件

- 一台运行 Ubuntu 的开发机，上面已经配置好：
  - BMS 工程的内核编译环境（生成 `zImage` 和 `imx6ull-bms-nand.dtb`）；  
  - Buildroot 或类似环境，根文件系统路径为：`/home/xixing/linux/nfs/buildroot/rootfs`；  
  - TFTP 目录：`/home/xixing/linux/tftpboot` 中能看到 `zImage` 和 `imx6ull-bms-nand.dtb`。  
- Windows 机上安装 PuTTY 套件，并将 `plink.exe`、`pscp.exe` 拷贝到本仓库目录。  
- Windows 机上存在 mfgtool 工程目录（脚本默认为）：  
  - `F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\boot`  
  - `F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\filesystem`

### 2. 首次使用前需要修改的地方

在 `update_from_ubuntu.ps1` / `update_from_ubuntu_full.ps1` 中，根据你的实际环境修改：

- `\$HostIp`：Ubuntu 主机 IP  
- `\$UserName`：登录 Ubuntu 的用户名  
- `\$Password`：对应用户密码（脚本中会用它执行 `sudo` 和 SCP）  
- 如有需要，可修改远程路径（rootfs / tftpboot）和本地 mfgtool 目录路径。

> 安全提示：  
> 脚本里目前是明文密码，只适合内部开发环境使用。若要在更严格的环境下使用，建议改成交互输入或更安全的凭证管理方式。

### 3. 在 Windows 上一键同步的步骤

1. 确认 Ubuntu 上已经完成内核、设备树、rootfs 的编译。  
2. 确认本机 `plink.exe`、`pscp.exe` 与本仓库脚本在同一目录。  
3. 在 Windows 中双击运行：  
   - `update_from_ubuntu.bat`：执行标准同步流程；  
   - 或 `update_from_ubuntu_full.bat`：执行“全量”同步（提示信息更详细）。  
4. 脚本会自动：  
   - 在 Ubuntu 上重新打包 `rootfs.tar.bz2`；  
   - 确保本地 mfgtool 目标目录存在；  
   - 拷贝最新的 `zImage`、`imx6ull-bms-nand.dtb` 和 `rootfs.tar.bz2` 到本机 mfgtool 目录。  
5. 同步完成后，可在 mfgtool 中按原有流程刷写到 BMS 板。

## Git 仓库与命名说明

- 推荐的 GitHub 仓库名字：`imx6ull-bms-update`。  
- 如果你当前仓库还叫 `1`，可以在 GitHub 网页上重命名：  
  1. 打开仓库页面（例如 `https://github.com/DARLUU/1`）；  
  2. 点击 `Settings` → `General`；  
  3. 在 “Repository name” 中改成 `imx6ull-bms-update`，保存即可。  

GitHub 会自动把旧地址重定向到新地址，所以本地已经配置好的远程 `origin` 仍然可以继续使用。如果你希望本地的远程地址也改成新名字对应的 URL，可以在本地仓库执行：

```bash
git remote set-url origin https://github.com/DARLUU/imx6ull-bms-update.git
```

之后再执行：

```bash
git push
```

就可以把后续改动推送到重命名后的仓库。

