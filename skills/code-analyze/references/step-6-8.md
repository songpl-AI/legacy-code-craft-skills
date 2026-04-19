# Step 6-8: 自检 + 老化检测 + 缓存

## Step 6 — 索引一致性自检

更新 script-index.md 和 event-index.md 后，执行以下检查：

1. **TAG 唯一性**：script-index.md 中不能有重复的 TAG
2. **脚本文件存在性**：索引中的脚本文件前缀能通过 `scripts/{FILE_PATTERN}*.lua` 找到对应文件
3. **事件一致性**：event-index.md 中引用的 TAG 必须在 script-index.md 中存在
4. **归档同步**：如果 `{AGENT_DIR}/{baseDir}/archive/scripts/{TAG}/` 目录存在，检查 `archive/index.json` 中是否有对应条目

如果发现不一致，在分析报告末尾输出警告：
```
⚠️ 索引一致性问题：
- TAG "xxx" 在 script-index.md 中重复出现
- 脚本 script_abc12345 在 scripts/ 目录中不存在
- event-index.md 中引用了未知 TAG "yyy"
```

---

## Step 7 — Memory 老化检测

在索引更新完成后，执行 Memory 老化检测：

1. 读取 `{AGENT_DIR}/{baseDir}/script-index.md`
2. 遍历所有条目，检查「最后分析」列的时间
3. **检测过时条目**：超过 30 天未更新的索引标记为 ⚠️ STALE
4. **输出老化报告**：
   ```
   ## Memory 老化检测

   | TAG | 脚本文件 | 最后分析 | 状态 |
   |-----|---------|---------|------|
   | {{TAG_NAME}} | script_abc12345 | 2026-03-01 | ⚠️ STALE (48天未更新) |
   | {{TAG_NAME}} | script_def67890 | 2026-04-10 | ✅ OK (8天前) |
   ```

5. **建议操作**：
   - 对 STALE 条目，建议执行 `/code-analyze 脚本路径 --refresh` 重新分析
   - 如相关功能已废弃，建议从索引中删除该条目

> 老化检测帮助保持索引的时效性，避免过时信息导致错误定位。

---

## Step 8 — 缓存写入（分析完成后执行）

如果执行了实际分析（而非直接返回缓存），将结果写入缓存：

1. 创建 `{AGENT_DIR}/{baseDir}/cache/` 目录（如不存在）
2. 将完整分析报告写入 `{AGENT_DIR}/{baseDir}/cache/{脚本key}.md`
3. 更新 `{AGENT_DIR}/{baseDir}/memory-cache.json`：
   ```json
   {
     "lastUpdated": "2026-04-18",
     "entries": {
       "script_key": {
         "analyzeTime": "2026-04-18T10:30:00Z",
         "ttl": 7,
         "reportPath": "{AGENT_DIR}/{baseDir}/cache/script_key.md"
       }
     }
   }
   ```
