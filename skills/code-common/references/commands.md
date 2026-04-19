# 子命令详解

## create

1. 将内容写入 `{AGENT_DIR}/{baseDir}/memory/common/{模块名}.md`
2. 更新 `index.json` 的 entries：
   ```json
   "entries": {
     "协议层规范": {
       "file": "协议层规范.md",
       "created": "2026-04-18",
       "updated": "2026-04-18",
       "summary": "HTTP 请求必须先检查 magic number..."
     }
   }
   ```
3. 输出创建确认

---

## list

1. 读取 `index.json` 的 entries
2. 输出列表：
   ```
   ## 公共知识列表

   | 模块 | 创建时间 | 摘要 |
   |------|---------|------|
   | 协议层规范 | 2026-04-18 | HTTP 请求必须先检查 magic number... |
   | 网络重连机制 | 2026-04-18 | 连接断开时，先等待 3 秒再重试... |
   ```

---

## search

1. 读取所有 `{AGENT_DIR}/{baseDir}/memory/common/*.md` 文件
2. 按关键词匹配内容
3. 输出匹配结果及所在文件