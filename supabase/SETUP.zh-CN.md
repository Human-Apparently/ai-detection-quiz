# 连接答卷数据库

你的项目地址是 `https://pvsllbsyacpacikoguze.supabase.co`。

## 第一步：建表和提交接口

1. 打开 Supabase 项目。
2. 在左侧点击 **SQL Editor**（`>_` 图标），然后点击 **New query**。
3. 打开同目录的 `setup.sql`，用 GitHub 文件右上角的复制按钮复制全部代码。
4. 粘贴到 SQL Editor，点击 **Run**。成功时一般显示 `Success. No rows returned`。
5. 在 **Table Editor** 中可以找到 `quiz_responses`。表刚创建时是空的。

代码只创建数据库表和一个提交函数；不会删除现有答卷。匿名参与者可以提交五道题的答案，但不能直接读取、修改或删除答卷表。得分由数据库计算；同一个提交 ID 重试不会产生重复行。

这是开放问卷的提交入口，不验证参与者身份，也不阻止同一个人使用新 ID 多次提交。收集时应请每人只提交一次；若需要更强的防刷能力，可以另加验证码或服务端限流。

## 第二步：连接网站

进入 **Project Settings → API Keys**，找到 **Publishable key**（通常以 `sb_publishable_` 开头）。旧版项目也可以使用标为 `anon public` 的公开密钥。

公开密钥是为浏览器访问准备的，不是数据库管理密码。不要使用 `Secret key`、`service_role` 或数据库密码。

网站 `config.js` 已预留 `supabaseUrl` 和 `publishableKey`。先保留 `collectionEnabled: false`；完成接口验证、确认数据库能收到数据后，再启用正式收集。

## 查看和导出答卷

在 Supabase **Table Editor → quiz_responses** 中查看。可用表格工具栏的 CSV 导出功能下载。数据库管理后台能查看记录，公开问卷页面不能浏览答卷表。

当前项目已连接并完成实际接口保存测试，网站已开启收集。测试记录 ID 和正式统计过滤语句见 `TEST_DATA.md`。
