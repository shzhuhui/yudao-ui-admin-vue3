#!/bin/bash
# 本地部署脚本 (macOS Shell)
# 用于本地构建和部署项目到 Azure Static Web Apps

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Azure Static Web Apps 配置
# 请设置环境变量: export AZURE_STATIC_YUDAO_ADMIN_UI=your_token
# 或者在下面直接填写 token (不推荐)
AZURE_TOKEN="${AZURE_STATIC_YUDAO_ADMIN_UI}"

echo -e "${GREEN}=== 开始本地部署 ===${NC}"
# 检查 Node.js 版本
echo -e "\n${YELLOW}检查 Node.js 版本...${NC}"
node --version

# 安装 PNPM（如果未安装）
echo -e "\n${YELLOW}检查 PNPM...${NC}"
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}正在安装 PNPM...${NC}"
    npm install -g pnpm
else
    echo -e "${GREEN}PNPM 已安装${NC}"
fi

# 安装 Azure Static Web Apps CLI（如果未安装）
echo -e "\n${YELLOW}检查 Azure Static Web Apps CLI...${NC}"
if ! command -v swa &> /dev/null; then
    echo -e "${YELLOW}正在安装 Azure Static Web Apps CLI...${NC}"
    npm install -g @azure/static-web-apps-cli
else
    echo -e "${GREEN}Azure Static Web Apps CLI 已安装${NC}"
fi

# 清理并安装依赖
echo -e "\n${YELLOW}清理旧依赖...${NC}"
rm -rf node_modules
rm -f pnpm-lock.yaml

echo -e "\n${YELLOW}安装依赖...${NC}"
pnpm install

# 构建项目
echo -e "\n${YELLOW}构建项目...${NC}"
npm run build:stage

# 检查构建是否成功
if [ ! -d "dist-stage" ]; then
    echo -e "${RED}错误: 构建失败，dist-stage 目录不存在${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== 构建完成 ===${NC}"
echo -e "${CYAN}构建产物位于: ./dist-stage 目录${NC}"

# 部署到 Azure Static Web Apps
echo -e "\n${GREEN}=== 部署到 Azure Static Web Apps ===${NC}"

if [ -z "$AZURE_TOKEN" ]; then
    echo -e "${RED}错误: 未设置 AZURE_TOKEN 环境变量${NC}"
    echo -e "${YELLOW}请运行: export AZURE_STATIC_YUDAO_ADMIN_UI=your_token${NC}"
    exit 1
fi

echo -e "${YELLOW}正在部署...${NC}"
swa deploy dist-stage --deployment-token "$AZURE_TOKEN" --env production

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}=== 部署成功 ===${NC}"
else
    echo -e "\n${RED}=== 部署失败 ===${NC}"
    exit 1
fi
