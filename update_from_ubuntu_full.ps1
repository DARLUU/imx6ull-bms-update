$HostIp   = "192.168.226.130"
$UserName = "xixing"
$Password = "201502"

$destBoot = "F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\boot"
$destFs   = "F:\working data\linux_bms\mfgtool-bms\Profiles\Linux\OS Firmware\files\filesystem"

# 获取脚本所在目录，定位 plink / pscp
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$plinkPath = Join-Path $scriptDir "plink.exe"
$pscpPath  = Join-Path $scriptDir "pscp.exe"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Ubuntu BMS 文件一键同步工具（全量：内核+dtb+uboot+rootfs）" -ForegroundColor Cyan
Write-Host " 目标主机: $HostIp  用户: $UserName" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $plinkPath))
{
    Write-Host "[错误] 未找到 plink.exe：$plinkPath" -ForegroundColor Red
    Write-Host "        请确认它和本脚本在同一目录。" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

if (-not (Test-Path $pscpPath))
{
    Write-Host "[错误] 未找到 pscp.exe：$pscpPath" -ForegroundColor Red
    Write-Host "        请确认它和本脚本在同一目录。" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

# 步骤1：远程打包 rootfs
Write-Host "步骤1：在 Ubuntu 上重新打包 rootfs.tar.bz2" -ForegroundColor Yellow
Write-Host "  - 删除旧 rootfs.tar.bz2" -ForegroundColor DarkYellow
Write-Host "  - 重新压缩当前 rootfs 目录" -ForegroundColor DarkYellow

$remoteCmd = "cd /home/xixing/linux/nfs/buildroot/rootfs; echo $Password | sudo -S rm -f rootfs.tar.bz2; echo $Password | sudo -S tar -jcvf rootfs.tar.bz2 *"

"y" | & $plinkPath -pw $Password "$UserName@${HostIp}" $remoteCmd
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 远程打包 rootfs.tar.bz2 失败，请检查 IP、密码或 sudo 权限。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 步骤2：确保本地目录存在
Write-Host "" 
Write-Host "步骤2：确保本地目标目录存在" -ForegroundColor Yellow
foreach ($p in @($destBoot, $destFs))
{
    if (-not (Test-Path $p))
    {
        New-Item -Path $p -ItemType Directory -Force | Out-Null
    }
}

# 步骤3：拷贝 zImage
Write-Host "" 
Write-Host "步骤3：拷贝 zImage 到 boot 目录" -ForegroundColor Yellow
& $pscpPath -pw $Password "$UserName@${HostIp}:/home/xixing/linux/tftpboot/zImage" $destBoot
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 拷贝 zImage 失败，请检查网络或远程路径。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 步骤4：拷贝 dtb
Write-Host "" 
Write-Host "步骤4：拷贝 imx6ull-bms-nand.dtb 到 boot 目录" -ForegroundColor Yellow
& $pscpPath -pw $Password "$UserName@${HostIp}:/home/xixing/linux/tftpboot/imx6ull-bms-nand.dtb" $destBoot
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 拷贝 imx6ull-bms-nand.dtb 失败，请检查网络或远程路径。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 步骤5：拷贝 u-boot-imx6ull-bms-ddr512-nand.imx 到 boot 目录
Write-Host "" 
Write-Host "步骤5：拷贝 u-boot-imx6ull-bms-ddr512-nand.imx 到 boot 目录" -ForegroundColor Yellow
& $pscpPath -pw $Password "$UserName@${HostIp}:/home/xixing/alientek/mini_linux/Linux/bms/uboot/uboot-imx-rel_imx_4.1.15_2.1.0_ga_alientek/u-boot-imx6ull-bms-ddr512-nand.imx" $destBoot
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 拷贝 u-boot-imx6ull-bms-ddr512-nand.imx 失败，请检查网络或远程路径。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 步骤6：拷贝 u-boot-imx6ull-bms-ddr512-nand.bin 到 boot 目录
Write-Host "" 
Write-Host "步骤6：拷贝 u-boot-imx6ull-bms-ddr512-nand.bin 到 boot 目录" -ForegroundColor Yellow
& $pscpPath -pw $Password "$UserName@${HostIp}:/home/xixing/alientek/mini_linux/Linux/bms/uboot/uboot-imx-rel_imx_4.1.15_2.1.0_ga_alientek/u-boot-imx6ull-bms-ddr512-nand.bin" $destBoot
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 拷贝 u-boot-imx6ull-bms-ddr512-nand.bin 失败，请检查网络或远程路径。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 步骤7：拷贝 rootfs.tar.bz2 到 filesystem
Write-Host "" 
Write-Host "步骤7：拷贝 rootfs.tar.bz2 到 filesystem 目录" -ForegroundColor Yellow
& $pscpPath -pw $Password "$UserName@${HostIp}:/home/xixing/linux/nfs/buildroot/rootfs/rootfs.tar.bz2" $destFs
if ($LASTEXITCODE -gt 1)
{
    Write-Host "[错误] 拷贝 rootfs.tar.bz2 到 filesystem 目录失败，请检查网络或远程路径。" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "" 
Write-Host "完成：所有文件已同步：" -ForegroundColor Green
Write-Host "  - zImage" -ForegroundColor Green
Write-Host "  - imx6ull-bms-nand.dtb" -ForegroundColor Green
Write-Host "  - u-boot-imx6ull-bms-ddr512-nand.imx" -ForegroundColor Green
Write-Host "  - u-boot-imx6ull-bms-ddr512-nand.bin" -ForegroundColor Green
Write-Host "  - rootfs.tar.bz2 （仅 filesystem 目录）" -ForegroundColor Green

Read-Host "任务结束，按回车键退出"

