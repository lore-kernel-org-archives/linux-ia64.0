From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat, 25 Feb 2012 23:24:31 +0000
Subject: [PATCH] ia64: fix warning from machine_kexec.c
Message-Id: <1330212271-23921-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use proper cpp defined(...) constructs to avoid this:

arch/ia64/kernel/machine_kexec.c: In function 'arch_crash_save_vmcoreinfo':
arch/ia64/kernel/machine_kexec.c:160:8: warning: "CONFIG_PGTABLE_4" is not defined

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

---

[seen in linux-next-20120224 tree; probably also an issue in mainline]

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 4eed358..070e8ef 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -157,7 +157,7 @@ void arch_crash_save_vmcoreinfo(void)
 #endif
 #ifdef CONFIG_PGTABLE_3
 	VMCOREINFO_CONFIG(PGTABLE_3);
-#elif  CONFIG_PGTABLE_4
+#elif defined(CONFIG_PGTABLE_4)
 	VMCOREINFO_CONFIG(PGTABLE_4);
 #endif
 }
-- 
1.7.9.1

