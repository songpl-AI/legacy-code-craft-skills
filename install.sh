#!/bin/bash
# Game Dev Skills 工具集 - 安装脚本
# 用法: bash install.sh /path/to/your/project [--agent claude|codex|cursor|auto] [--engine unity|lua|unreal|godot]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ========== 自动检测 Agent ==========
detect_agent() {
    if command -v claude &> /dev/null || [ -n "$CLAUDE_SESSION_ID" ]; then
        echo "claude"
        return
    fi
    if command -v codex &> /dev/null || [ -n "$CODEX_API_KEY" ]; then
        echo "codex"
        return
    fi
    if [ -d "$HOME/.cursor" ] || [ -d "$HOME/AppData/Roaming/Cursor" ]; then
        echo "cursor"
        return
    fi
    if [ -n "$VSCODE_CLI" ] || [ -n "$VSCODE_IPC_HOOK" ]; then
        echo "vscode"
        return
    fi
    echo ""
}

# ========== 自动检测引擎 ==========
detect_engine() {
    if [ -f "$1/scripts/fsync_*.lua" ] || [ -d "$1/lua" ]; then
        echo "lua"
        return
    fi
    if [ -f "$1/ProjectSettings/ProjectVersion.txt" ] || find "$1" -name "*.csproj" -maxdepth 2 | head -1 | grep -q .; then
        echo "unity"
        return
    fi
    if [ -f "$1/Config/DefaultEngine.ini" ]; then
        echo "unreal"
        return
    fi
    if [ -f "$1/project.godot" ]; then
        echo "godot"
        return
    fi
    echo "lua"  # 默认 Lua
}

# ========== 创建项目配置文件 ==========
setup_project_config() {
    local target_config="$TARGET_DIR/$AGENT_DIR/$BASE_DIR/config/project.yaml"

    # 如果 project.yaml 已存在，跳过
    if [ -f "$target_config" ]; then
        echo -e "  -> project.yaml ${CYAN}已存在，保留${NC}"
        return
    fi

    # 如果存在 project-template.yaml，复制为 project.yaml
    local template_config="$TARGET_DIR/$AGENT_DIR/$BASE_DIR/config/project-template.yaml"
    if [ -f "$template_config" ]; then
        cp "$template_config" "$target_config"
        echo -e "  -> project.yaml ${GREEN}已创建${NC}"
    fi
}

# ========== 获取参数 ==========
TARGET_DIR=""
AGENT="auto"
ENGINE="auto"
BASE_DIR=""  # 项目数据目录，默认 project-data

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent)
            AGENT="$2"
            shift 2
            ;;
        --engine)
            ENGINE="$2"
            shift 2
            ;;
        --base-dir)
            BASE_DIR="$2"
            shift 2
            ;;
        --help)
            echo "用法: bash install.sh <目标目录> [--agent claude|codex|cursor|auto] [--engine unity|lua|unreal|godot|auto] [--base-dir 目录名]"
            echo ""
            echo "参数说明："
            echo "  --agent   指定 Agent 类型（默认自动检测）"
            echo "  --engine  指定游戏引擎（默认自动检测：lua/unity/unreal/godot）"
            echo "  --base-dir 指定项目数据目录（默认从 config/project.yaml 读取，或使用 project-data）"
            exit 0
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            fi
            shift
            ;;
    esac
done

# ========== 获取目标目录 ==========
if [ -z "$TARGET_DIR" ]; then
    echo ""
    echo -e "${BOLD}请输入项目根目录路径${NC}"
    echo ""
    read -p "  路径: " TARGET_DIR
fi

TARGET_DIR="${TARGET_DIR%/}"

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误: 目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ========== 检测 Agent 类型 ==========
if [ "$AGENT" = "auto" ]; then
    AGENT=$(detect_agent)
fi

while [ "$AGENT" = "" ]; do
    echo ""
    echo -e "${BOLD}无法自动检测 Agent 类型，请选择：${NC}"
    echo "  1) claude  - Claude Code"
    echo "  2) codex   - OpenAI Codex"
    echo "  3) cursor  - Cursor"
    echo "  4) vscode  - VS Code (Claude)"
    echo ""
    read -p "  选择 (1-4): " CHOICE
    case $CHOICE in
        1) AGENT="claude" ;;
        2) AGENT="codex" ;;
        3) AGENT="cursor" ;;
        4) AGENT="vscode" ;;
    esac
done

# ========== 确定 AGENT_DIR ==========
case $AGENT in
    claude)
        AGENT_DIR=".claude"
        SKILLS_DIR="$AGENT_DIR/skills"
        ;;
    codex)
        AGENT_DIR=".codex"
        SKILLS_DIR="$AGENT_DIR/skills"
        ;;
    cursor)
        AGENT_DIR=".cursor"
        SKILLS_DIR="$AGENT_DIR/skills"
        ;;
    vscode)
        AGENT_DIR=".vscode"
        SKILLS_DIR="$AGENT_DIR/claude/skills"
        ;;
esac

# ========== 确定 BASE_DIR ==========
# 优先级：1. 命令行参数 2. 目标项目已有配置 3. 默认值 project-data
if [ -z "$BASE_DIR" ]; then
    # 尝试从目标项目的旧配置读取（兼容 lua-skills 或其他自定义目录）
    for old_dir in lua-skills project-data game-skills; do
        old_config="$TARGET_DIR/$AGENT_DIR/$old_dir/config/project.yaml"
        if [ -f "$old_config" ]; then
            old_base=$(grep -A1 "^paths:" "$old_config" 2>/dev/null | grep "baseDir:" | sed 's/.*baseDir:*[ \t]*[""]*\([^" ]*\)[""]*/\1/' | tr -d '"' | tr -d "'")
            if [ -n "$old_base" ]; then
                BASE_DIR="$old_base"
                echo -e "  -> 检测到已有配置，目录: ${YELLOW}$BASE_DIR${NC}"
                break
            fi
        fi
    done

    # 如果仍未确定，使用默认值
    if [ -z "$BASE_DIR" ]; then
        BASE_DIR="project-data"
    fi
fi

# ========== 检测引擎类型 ==========
if [ "$ENGINE" = "auto" ]; then
    ENGINE=$(detect_engine "$TARGET_DIR")
fi

# 验证引擎
case $ENGINE in
    lua|unity|unreal|godot) ;;
    *)
        echo -e "${RED}未知的引擎: $ENGINE${NC}"
        echo "支持的引擎: lua, unity, unreal, godot"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo -e "  Game Dev Skills 工具集 - 安装"
echo -e "  Agent: ${GREEN}$AGENT${NC}"
echo -e "  引擎: ${GREEN}$ENGINE${NC}"
echo "======================================"
echo ""

# ========== 检测旧版安装 ==========
UPGRADE=false
if [ -d "$TARGET_DIR/$AGENT_DIR/commands" ]; then
    UPGRADE=true
    echo -e "${YELLOW}检测到旧版安装（commands/ 结构），将迁移到 skills/ 结构${NC}"
    echo ""
fi

# ========== 安装 Skills ==========
echo -e "${GREEN}[1/7]${NC} 安装 Skills..."

# 迁移旧版 skills（如果存在）
if [ -d "$TARGET_DIR/$AGENT_DIR/commands" ]; then
    echo "  -> 迁移旧版 commands/ 到 skills/"
    for SKILL in code-analyze code-modify code-common code-archive code-debug code-bugfix api-search code-req; do
        if [ -d "$TARGET_DIR/$AGENT_DIR/commands/$SKILL" ]; then
            mkdir -p "$TARGET_DIR/$SKILLS_DIR"
            cp -r "$TARGET_DIR/$AGENT_DIR/commands/$SKILL" "$TARGET_DIR/$SKILLS_DIR/"
        fi
    done
fi

# 安装新版 skills
SKILLS_OK=true
for SKILL in code-analyze code-modify code-common code-archive code-debug code-bugfix api-search code-req; do
    if [ -f "$SCRIPT_DIR/skills/$SKILL/SKILL.md" ]; then
        mkdir -p "$TARGET_DIR/$SKILLS_DIR"
        rm -rf "$TARGET_DIR/$SKILLS_DIR/$SKILL"
        cp -r "$SCRIPT_DIR/skills/$SKILL" "$TARGET_DIR/$SKILLS_DIR/"
        echo -e "  $SKILL ${GREEN}OK${NC}"
    else
        echo -e "  $SKILL ${RED}MISSING${NC}"
        SKILLS_OK=false
    fi
done

# ========== 安装引擎配置 ==========
echo -e "${GREEN}[2/7]${NC} 引擎配置..."

if [ -d "$SCRIPT_DIR/config" ]; then
    mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/config"
    cp -r "$SCRIPT_DIR/config/"* "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/config/"
    echo -e "  -> config/ ${GREEN}OK${NC}"
    echo "  -> 当前引擎: $ENGINE"
else
    echo -e "  -> config/ ${YELLOW}SKIP (未找到)${NC}"
fi

# 写入当前引擎选择
echo "$ENGINE" > "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/config/current-engine.txt"

# 创建 project.yaml（从 template 复制）
setup_project_config

# ========== 创建项目数据目录 ==========
echo -e "${GREEN}[3/7]${NC} 项目数据目录..."
mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR"
mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/archive/scripts"
mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/memory/common"
mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/bugs"
mkdir -p "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/cache"
mkdir -p "$TARGET_DIR/scriptsBackup"
echo "  -> $AGENT_DIR/$BASE_DIR/"

# ========== 索引文件（仅首次） ==========
echo -e "${GREEN}[4/7]${NC} 索引文件..."

if [ ! -f "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/script-index.md" ]; then
cat > "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/script-index.md" << INDEXEOF
# 脚本功能索引表

> 由 \`/code-analyze\` 自动维护
> **TAG 是主键**（稳定标识），脚本文件名为 UUID 格式，两者同时记录

| TAG | 脚本文件 | 功能定位 | 关键功能 |
|-----|---------|---------|---------|

<!-- INDEX_END：/code-analyze 自动在此标记前插入新条目 -->
INDEXEOF
    echo "  -> script-index.md (新建)"
else
    echo -e "  -> script-index.md (${CYAN}已存在，保留${NC})"
fi

if [ ! -f "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/event-index.md" ]; then
cat > "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/event-index.md" << EVENTEOF
# 事件索引表

> 由 \`/code-analyze\` 自动维护
> **TAG 是主键**，修改 Fire 前先查此表

| 事件名 | 类型 | TAG | 脚本文件 | 函数 |
|--------|------|-----|---------|------|

<!-- EVENT_INDEX_END：/code-analyze 自动在此标记前插入新条目 -->
EVENTEOF
    echo "  -> event-index.md (新建)"
else
    echo -e "  -> event-index.md (${CYAN}已存在，保留${NC})"
fi

# ========== 版本和 gitignore ==========
echo -e "${GREEN}[5/7]${NC} 版本和配置..."

cp "$SCRIPT_DIR/version.json" "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/version.json"

GITIGNORE_ENTRIES="$AGENT_DIR/$BASE_DIR/api-doc-config.json
$AGENT_DIR/$BASE_DIR/config/current-engine.txt
.DS_Store"

if [ -f "$TARGET_DIR/.gitignore" ]; then
    ADDED=0
    while IFS= read -r entry; do
        if ! grep -qF "$entry" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            echo "$entry" >> "$TARGET_DIR/.gitignore"
            ADDED=1
        fi
    done <<< "$GITIGNORE_ENTRIES"
    [ "$ADDED" -eq 1 ] && echo "  -> .gitignore (已更新)"
else
    cat > "$TARGET_DIR/.gitignore" << GIEOF
# API Doc Token 配置（含敏感信息，禁止提交）
\$AGENT_DIR/$BASE_DIR/api-doc-config.json
# 当前引擎配置
\$AGENT_DIR/$BASE_DIR/config/current-engine.txt
.DS_Store
GIEOF
    echo "  -> .gitignore (新建)"
fi

# ========== API Doc 配置（可选） ==========
echo -e "${GREEN}[6/7]${NC} API Doc 配置..."

if [ ! -f "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/api-doc-config.json" ]; then
    echo ""
    echo -e "  ${CYAN}API Doc 用于接口文档搜索，可跳过。${NC}"
    read -p "  是否现在配置 API Doc Token？(y/n): " CONFIGURE_API_DOC

    if [ "$CONFIGURE_API_DOC" = "y" ] || [ "$CONFIGURE_API_DOC" = "Y" ]; then
        echo ""
        echo "  Token 获取：API Doc → 项目 → 设置 → Token配置"
        read -p "  API Doc baseUrl (默认 https://api.example.com): " API_DOC_URL
        API_DOC_URL="${API_DOC_URL:-https://api.example.com}"
        read -p "  projectId (默认 123): " API_DOC_PROJECT
        API_DOC_PROJECT="${API_DOC_PROJECT:-123}"
        read -p "  请粘贴 Token: " API_DOC_TOKEN

        if [ -n "$API_DOC_TOKEN" ]; then
            cat > "$TARGET_DIR/$AGENT_DIR/$BASE_DIR/api-doc-config.json" << APIEOF
{
  "baseUrl": "$API_DOC_URL",
  "projectId": "$API_DOC_PROJECT",
  "token": "$API_DOC_TOKEN"
}
APIEOF
            echo -e "  -> api-doc-config.json (已配置)"
        fi
    else
        echo "  -> 跳过"
    fi
else
    echo -e "  -> api-doc-config.json (${CYAN}已存在${NC})"
fi

# ========== 清理旧版（如果存在） ==========
echo -e "${GREEN}[7/7]${NC} 清理..."

if [ -d "$TARGET_DIR/$AGENT_DIR/commands" ]; then
    echo "  -> 删除旧版 commands/ 目录"
    rm -rf "$TARGET_DIR/$AGENT_DIR/commands"
fi

if [ -d "$TARGET_DIR/$AGENT_DIR/reference" ]; then
    rm -rf "$TARGET_DIR/$AGENT_DIR/reference"
fi

# ========== 完成 ==========
echo ""
echo "======================================"
echo -e "  ${GREEN}安装完成！${NC}"
echo "======================================"

echo ""
echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}  如果 Agent 正在运行，需要重启！${NC}"
echo -e "${YELLOW}======================================${NC}"
echo ""
echo "  项目结构："
echo "  $TARGET_DIR/"
echo "  ├── $AGENT_DIR/"
echo "  │   ├── skills/              <- Skills 已安装"
echo "  │   │   ├── code-analyze/"
echo "  │   │   ├── code-modify/"
echo "  │   │   └── ..."
echo "  │   └── $BASE_DIR/         <- 项目数据"
echo "  │       ├── script-index.md"
echo "  │       ├── event-index.md"
echo "  │       ├── config/          <- 引擎配置"
echo "  │       ├── archive/"
echo "  │       └── memory/"
echo "  └── scriptsBackup/"
echo ""
echo "  引擎: $ENGINE"
echo "  切换引擎: 修改 $AGENT_DIR/$BASE_DIR/config/current-engine.txt"
echo ""
