From: Luis Chamberlain <mcgrof@kernel.org>
Date: Fri, 10 Mar 2023 23:24:16 +0000
Subject: [PATCH] ia64: simplify one-level sysctl registration for kdump_ctl_table
Message-Id: <20230310232416.3958751-1-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: ebiederm@xmission.com, keescook@chromium.org, yzaikin@google.com, j.granados@samsung.com, patches@lists.linux.dev, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Luis Chamberlain <mcgrof@kernel.org>

There is no need to declare an extra tables to just create directory,
this can be easily be done with a prefix path with register_sysctl().

Simplify this registration.

Signed-off-by: Luis Chamberlain <mcgrof@kernel.org>
---

If ia64 is not removed from the kernel feel free to take this or I can
take it through sysctl-next.

 arch/ia64/kernel/crash.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index 76730f34685c..88b3ce3e66cd 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -234,15 +234,6 @@ static struct ctl_table kdump_ctl_table[] = {
 	},
 	{ }
 };
-
-static struct ctl_table sys_table[] = {
-	{
-	  .procname = "kernel",
-	  .mode = 0555,
-	  .child = kdump_ctl_table,
-	},
-	{ }
-};
 #endif
 
 static int
@@ -257,7 +248,7 @@ machine_crash_setup(void)
 	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
 		return ret;
 #ifdef CONFIG_SYSCTL
-	register_sysctl_table(sys_table);
+	register_sysctl("kernel", kdump_ctl_table);
 #endif
 	return 0;
 }
-- 
2.39.1
