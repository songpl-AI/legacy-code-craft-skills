# 配置（首次使用必读）

## Step 0 — 检查配置

从 `{API_CONFIG_PATH}` 读取配置：

```json
{
  "baseUrl": "{{API_DOC_BASE_URL}}",
  "projectId": "{{API_DOC_PROJECT_ID}}",
  "token": "your-token-here"
}
```

**如果配置文件不存在或缺少字段**，提示用户：

```
API Doc 配置缺失，请创建配置文件：

路径：{API_CONFIG_PATH}

内容：
{
  "baseUrl": "{{API_DOC_BASE_URL}}",
  "projectId": "{{API_DOC_PROJECT_ID}}",
  "token": "获取方式见下方说明"
}

Token 获取方式：
1. 登录 {{API_DOC_BASE_URL}}
2. 进入项目 → 设置 → Token配置
3. 复制项目 Token 到配置文件

配置完成后重新执行 /api-search
```

⚠️ **安全提示**：`{{API_DOC_CONFIG_PATH}}` 包含 Token，已加入 `.gitignore`，**禁止提交到 Git 仓库**。
