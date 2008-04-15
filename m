From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Tue, 15 Apr 2008 09:59:54 +0000
Subject: [PATCH] ia64 kdump: Add crash_save_vmcoreinfo for INIT
Message-Id: <F5C89EDF745860indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, kexec@lists.infradead.org

Hi,

This patch fixes the problem that kdump by INIT does not work if we use
makedumpfile. The problem is that after INIT is issued, 2nd kernel
starts and makedumpfile fails with the following error message.

/proc/vmcore doesn't contain vmcoreinfo.
'-x' or '-i' must be specified.

makedumpfile Failed.

The cause of this problem is that kernel does not call
crash_save_vmcoreinfo. When kdump starts by panic or sysrq-trigger,
crash_save_vmcoreinfo is called by crash_kexec. But this function is not
called when kdump starts by INIT. The Attached patch fixes this.

This patch just adds crash_save_vmcoreinfo into machine_kdump_on_init so
that crash_save_vmcoreinfo can be called when kdump starts by INIT.
I tested this patch with linux-2.6.25-rc9 and I confirmed it worked.

Thanks,
Takao Indoh

Signed-off-by: Takao Indoh <indou.takao@jp.fujitsu.com>

---
 arch/ia64/kernel/crash.c |    1 +
 1 file changed, 1 insertion(+)

diff -Nurp linux-2.6.25-rc9.org/arch/ia64/kernel/crash.c linux-2.6.25-rc9/arch/ia64/kernel/crash.c
--- linux-2.6.25-rc9.org/arch/ia64/kernel/crash.c	2008-04-14 18:23:13.000000000 -0400
+++ linux-2.6.25-rc9/arch/ia64/kernel/crash.c	2008-04-14 18:25:46.000000000 -0400
@@ -118,6 +118,7 @@ machine_crash_shutdown(struct pt_regs *p
 static void
 machine_kdump_on_init(void)
 {
+	crash_save_vmcoreinfo();
 	local_irq_disable();
 	kexec_disable_iosapic();
 	machine_kexec(ia64_kimage);

