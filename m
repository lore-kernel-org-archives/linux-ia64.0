From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Sat, 11 Sep 2004 00:14:06 +0000
Subject: [PATCH] Online CPU with maxcpus option panics
Message-Id: <20040910171405.A28196@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Andrew,
	I booted IA64 kernel with "maxcpus=" set to less than
the total available processors in the system. Then I tried
to online the CPU which was offline due to "maxcpus=" restirction.
i.e  when I tried to online the CPU which never was online at boot
crashed the system.

Attached patch fixes the problem.

Please apply.

Signed-off-by: Anil Keshavamurthy <anil.s.keshavamurthy@intel.com>

---

 linux-2.6.9-rc1-mm2-askeshav/arch/ia64/kernel/smpboot.c |    2 +-
 linux-2.6.9-rc1-mm2-askeshav/kernel/fork.c              |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/ia64/kernel/smpboot.c~maxcpufix arch/ia64/kernel/smpboot.c
--- linux-2.6.9-rc1-mm2/arch/ia64/kernel/smpboot.c~maxcpufix	2004-09-09 16:30:01.497896672 -0700
+++ linux-2.6.9-rc1-mm2-askeshav/arch/ia64/kernel/smpboot.c	2004-09-09 16:33:21.626800471 -0700
@@ -356,7 +356,7 @@ start_secondary (void *unused)
 	return cpu_idle();
 }
 
-struct pt_regs * __init idle_regs(struct pt_regs *regs)
+struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
 {
 	return NULL;
 }
diff -puN kernel/fork.c~maxcpufix kernel/fork.c
--- linux-2.6.9-rc1-mm2/kernel/fork.c~maxcpufix	2004-09-09 16:30:17.358248041 -0700
+++ linux-2.6.9-rc1-mm2-askeshav/kernel/fork.c	2004-09-09 16:31:17.844575425 -0700
@@ -1069,13 +1069,13 @@ bad_fork_free:
 	goto fork_out;
 }
 
-struct pt_regs * __init __attribute__((weak)) idle_regs(struct pt_regs *regs)
+struct pt_regs * __devinit __attribute__((weak)) idle_regs(struct pt_regs *regs)
 {
 	memset(regs, 0, sizeof(struct pt_regs));
 	return regs;
 }
 
-task_t * __init fork_idle(int cpu)
+task_t * __devinit fork_idle(int cpu)
 {
 	task_t *task;
 	struct pt_regs regs;
_
