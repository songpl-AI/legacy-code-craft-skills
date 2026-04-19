# 缓存机制

## 缓存结构

```json
{
  "lastUpdate": "2026-04-08T00:00:00Z",
  "categories": [
    {
      "id": 1234,
      "name": "分类名称",
      "interfaces": [
        {
          "id": 12345,
          "title": "接口名称",
          "path": "/v3/module/api-path",
          "method": "POST"
        }
      ]
    }
  ]
}
```

## 缓存有效性检查

- `lastUpdate` 距今 > 7 天 → 缓存过期，重新拉取
- 缓存文件不存在 → 首次拉取

## 拉取或更新缓存

### 2.1 获取分类列表
```bash
curl -s "{{API_DOC_BASE_URL}}/api/interface/getCatMenu?project_id={{API_DOC_PROJECT_ID}}&token=TOKEN"
```

### 2.2 获取每个分类下的接口列表
```bash
curl -s "{{API_DOC_BASE_URL}}/api/interface/list_cat?catid=分类ID&token=TOKEN&page=1&limit=100"
```

### 2.3 更新缓存文件
将拉取的数据写入 `{API_CACHE_PATH}`，更新 `lastUpdate` 为当前时间

**错误处理：**
- 网络请求失败，有旧缓存 → 使用旧缓存并提示"缓存可能过期"
- 网络失败且无缓存 → 提示检查网络或配置

## 手动刷新缓存
```
/api-search --refresh
```
强制重新拉取所有分类和接口，忽略缓存

## 查看缓存状态
```
/api-search --status
```
显示缓存更新时间和接口数量
