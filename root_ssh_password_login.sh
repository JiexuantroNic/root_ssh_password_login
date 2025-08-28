#!/bin/bash

# root_ssh_password_login.sh
# 脚本功能：配置 Debian 12，允许 root 用户通过 SSH 密码登录。
# 适用场景：仅限内网环境！公网使用极其危险！
# 使用方法：sudo bash root_ssh_password_login.sh

set -e # 如果任何命令执行失败，则退出脚本

echo "正在配置 SSH 以允许 root 密码登录（适用于内网环境）..."
echo "警告：此配置在公网环境中存在重大安全风险！"

# 1. 确保脚本以 root 权限运行
if [[ $EUID -ne 0 ]]; then
   echo "错误：此脚本必须以 root 权限运行。请使用 sudo。" 
   exit 1
fi

# 2. 备份原始的 SSH 配置文件
echo "正在备份原始配置文件到 /etc/ssh/sshd_config.backup..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
echo "备份完成。"

# 3. 为 root 用户设置密码
echo "请为 root 用户设置一个用于 SSH 登录的密码："
passwd root

# 4. 配置 SSH 服务：允许 root 密码登录
echo "正在修改 /etc/ssh/sshd_config ..."

# 允许 Root 登录
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 确保密码认证是开启的
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 对于较新版本，可能还需要确保认证方法包含密码
sed -i 's/^#*AuthenticationMethods.*/AuthenticationMethods password/' /etc/ssh/sshd_config

echo "SSH 配置修改完成。"

# 5. 验证配置文件语法是否正确
if /usr/sbin/sshd -t > /dev/null 2>&1; then
    echo "SSH 配置文件语法测试通过。"
else
    echo "错误：SSH 配置文件语法有误。请检查修改或恢复备份。"
    exit 1
fi

# 6. 重新启动 SSH 服务以应用更改
echo "正在重启 SSH 服务..."
systemctl restart ssh

# 7. 输出最终状态和信息
echo ""
echo "========================================"
echo "配置完成！"
echo "========================================"
echo "当前 SSH 配置："
echo "  • PermitRootLogin: $(grep '^PermitRootLogin' /etc/ssh/sshd_config)"
echo "  • PasswordAuthentication: $(grep '^PasswordAuthentication' /etc/ssh/sshd_config)"
echo ""
echo "现在你可以使用以下命令连接："
echo "ssh root@你的服务器IP"
echo ""
echo "重要提示："
echo "1. 此配置仅建议在内网等安全环境中使用！"
echo "2. 请确保为 root 账户设置了强密码。"
echo "3. 备份文件位于 /etc/ssh/sshd_config.backup。"
echo "4. 请在另一个终端窗口测试登录，确认成功后再关闭当前会话！"
echo "========================================"