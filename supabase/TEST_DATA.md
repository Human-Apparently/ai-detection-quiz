# 数据库连接验证记录

连接验证使用了 **1 条测试答卷**。请在研究统计和正式数据导出中排除以下 ID：

`00000000-0000-4000-8000-000000000001`

该记录的总用时与每题用时均为 0，得分为 0。重试使用相同 ID，已验证数据库返回原始得分且不覆盖记录。

在 Supabase SQL Editor 中统计正式答卷数量：

```sql
select count(*) as participant_responses
from public.quiz_responses
where id <> '00000000-0000-4000-8000-000000000001'::uuid;
```

查看正式答卷：

```sql
select *
from public.quiz_responses
where id <> '00000000-0000-4000-8000-000000000001'::uuid
order by created_at;
```

以上查询在 Supabase 管理后台运行。公开网页没有读取答卷表的权限。

已验证：合法提交返回 HTTP 200；无同意声明的提交返回 HTTP 400；匿名读取答卷表返回 HTTP 401；浏览器跨域预检通过。尚未完成真实浏览器内的端到端检查（执行环境缺少浏览器可执行文件）。
