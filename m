From: Horms <horms@verge.net.au>
Date: Mon, 19 Jun 2006 06:47:12 +0000
Subject: [PATCH] ia64, kexec: elfcorehdr needs CONFIG_PROC_VMCORE
Message-Id: <20060619064710.GA11262@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64, kexec: elfcorehdr needs CONFIG_PROC_VMCORE

elfcoreheader is part of the functionality provided by CONFIG_PROC_VMCORE,
not CONFIG_CRASH_DUMP, although CONFIG_PROC_VMCORE depends on CONFIG_CRASH_DUMP.

Without this change the build will fail, complaining that the symbol elfcorehdr
doesn't exist, if the config has CONFIG_CRASH_DUMP but not CONFIG_PROC_VMCORE.

This patch is relative to Zou Nan hai's kdump patch which I rediffed
and sent to linux-ia64 and fastboot on the 8th of June
http://permalink.gmane.org/gmane.linux.ports.ia64/14320

Signed-off-by: Horms <horms@verge.net.au>

 arch/ia64/kernel/setup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

8190ca8bb167bbb92a61f686de02a5cc16c54800
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 7665d4d..74249ff 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -512,7 +512,7 @@ #endif
 	if (!nomca)
 		ia64_mca_init();
 
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_PROC_VMCORE
 	{
 		char *from = strstr(saved_command_line, "elfcorehdr=");
 

-- 
Horms                                           http://www.vergenet.net/~horms/

