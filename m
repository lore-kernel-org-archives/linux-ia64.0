From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 22 Jan 2022 17:48:34 +0000
Subject: [PATCH -next] exit: export make_task_dead()
Message-Id: <20220122174834.6493-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, kernel test robot <lkp@intel.com>

In a config file from "kernel test robot <lkp@intel.com>" for a
different problem, this linker error was exposed when
CONFIG_IA64_MCA_RECOVERY=m.

We could either export make_task_dead() or restrict IA64_MCA_RECOVERY
to a bool Kconfig symbol instead of a tristate symbol, so go with the
EXPORT_SYMBOL() path.

Fixes this build error:

ERROR: modpost: "make_task_dead" [arch/ia64/kernel/mca_recovery.ko] undefined!

Fixes: 0e25498f8cd4 ("exit: Add and use make_task_dead.")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: kernel test robot <lkp@intel.com>
---
 kernel/exit.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20220121.orig/kernel/exit.c
+++ linux-next-20220121/kernel/exit.c
@@ -896,6 +896,7 @@ void __noreturn make_task_dead(int signr
 
 	do_exit(signr);
 }
+EXPORT_SYMBOL(make_task_dead);
 
 SYSCALL_DEFINE1(exit, int, error_code)
 {
