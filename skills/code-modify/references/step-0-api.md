# Step 0: 解析 API Doc 接口

如果用户输入中包含 API Doc URL，执行此步骤。

## 解析流程

1. **从 URL 中提取接口 ID**（URL 末尾的数字，如 `181311`）

2. **读取 API Doc 配置文件**：
   ```bash
   cat {API_CONFIG_PATH}
   ```
   - 如果配置文件不存在或缺少 token，**停止流程**，提示用户配置：
     ```
     API Doc Token 未配置，无法自动解析接口文档。

     请按以下步骤配置：
     1. 在浏览器中打开 {{API_DOC_BASE_URL}} → 进入项目 → 设置 → Token配置
     2. 复制项目 Token
     3. 将 Token 告诉我，我来创建配置文件

     配置完成后请重新执行本次命令。
     ```

3. **调用 API Doc 获取接口详情**：
   ```bash
   curl -s "{{API_DOC_BASE_URL}}/api/interface/get?id=接口ID&token=TOKEN"
   ```

4. **从返回数据中提取**：
   - **接口路径**：`data.path`（如 `/v3/module/api`）
   - **请求方法**：`data.method`（如 `POST`）
   - **请求参数**：`data.req_body_other`（Body JSON）
   - **返回数据**：`data.res_body`（返回 JSON 示例）
   - **备注**：`data.markdown`（优先）或 `data.desc`，包含失败示例、错误码等

5. **输出解析摘要**，让用户确认：
   ```
   ## API Doc 接口解析

   - **接口**：接口标题
   - **路径**：POST /v3/xxx/yyy
   - **请求参数**：{ key: type, ... }
   - **返回字段**：data.success, data.error_code, data.msg ...
   - **备注**：错误码说明、失败示例等（完整展示）
   ```

> 解析完成后继续 Step 1，编写代码时严格按照解析出的接口文档实现
