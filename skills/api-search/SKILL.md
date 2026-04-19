---
name: api-search
description: 搜索接口文档，获取接口参数和返回值定义。**每次联调接口前用它**确认参数格式，**每次新增 HTTP 请求时用它**获取接口定义。带缓存机制，支持关键词模糊搜索。配置于 config/project.yaml 的 apiDoc 节点。
allowed-tools: Read Write Bash Grep Glob
---

# api-search

## 输入

```
/api-search <关键词>
/api-search --refresh   # 强制刷新缓存
/api-search --status    # 查看缓存状态
```

## 执行流程

| Step | 内容 |
|------|------|
| 1 | 检查配置 `config/project.yaml` 的 `apiDoc` 节点 |
| 2 | 加载缓存（`{API_CACHE_PATH}`），检查是否过期（>7天） |
| 3 | 关键词搜索（中文匹配 title，英文匹配 path） |
| 4 | 多匹配时让用户选择接口编号 |
| 5 | 获取接口详情 |
| 6 | 输出接口文档 + Lua 调用示例 |

详细配置见 `references/config.md`
缓存机制见 `references/cache.md`
Lua 示例模板见 `references/lua-example.md`

---

## 配置（首次使用）

首次使用需配置 `config/project.yaml`：

```yaml
apiDoc:
  type: "{{API_DOC_TYPE}}"  # {{API_DOC_TYPE_NAME}} / swagger / none
  {{API_DOC_TYPE}}:
    baseUrl: "https://{{API_DOC_HOST}}"
    projectId: "{{API_DOC_PROJECT_ID}}"
    configPath: "{{API_DOC_CONFIG_PATH}}"  # 认证token，不提交到git
    cachePath: "{{API_DOC_CACHE_PATH}}"
```

⚠️ Token 已加入 `.gitignore`，禁止提交

---

## 输出格式

```
## 接口：接口标题

- **路径**：POST /v3/xxx/yyy
- **分类**：分类名称

### 请求参数
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| key1 | string | 是 | 描述 |

### 返回数据
```json
{
  "code": 0,
  "msg": "success",
  "data": { ... }
}
```

### Lua 调用示例
[见 references/lua-example.md]
```

---

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| 搜索不到接口 | 尝试 `--refresh` 刷新缓存 |
| 网络请求失败 | 检查 Token 是否正确 |
| 缓存过期 | `/api-search --refresh` 强制刷新 |
