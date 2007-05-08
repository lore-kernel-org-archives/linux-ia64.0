From: Simon Horman <horms@verge.net.au>
Date: Tue, 08 May 2007 09:31:16 +0000
Subject: [patch 2/3] Use per-cpu elf_prstatus
Message-Id: <20070508093329.088911844@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070508093114.767199973@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fastboot@lists.osdl.org, kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Nanhai Zou <nanhai.zou@intel.com>, Vivek Goyal <vgoyal@in.ibm.com>, Tony Luck <tony.luck@intel.com>

Use a pre-allocated per-cpu variable for saving the cpu registers, as per
the IA64 specific code. This is in order to reduce possible stack
contention at crash-time as per the inline comment.

A following patch will update ia64 to use crash_save_cpu() rather
than its own re-implementation of the routine.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
 linux-2.6/kernel/kexec.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

Index: linux-2.6/kernel/kexec.c
=================================--- linux-2.6.orig/kernel/kexec.c	2007-05-08 18:08:50.000000000 +0900
+++ linux-2.6/kernel/kexec.c	2007-05-08 18:22:45.000000000 +0900
@@ -1097,9 +1097,18 @@ static void final_note(u32 *buf)
 	memcpy(buf, &note, sizeof(note));
 }
 
+/*
+ * There is some concern that on architectures where struct elf_prstatus is
+ * large, such as IA64, having elf_prstatus on the stack in
+ * crash_save_cpu() could cause problems given that this function
+ * is run after a kernel crash has occured. To aleviate this problem
+ * a pre-allocated per-cpu value is used instead.
+ */
+static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
+
 void crash_save_cpu(struct pt_regs *regs, int cpu)
 {
-	struct elf_prstatus prstatus;
+	struct elf_prstatus *prstatus;
 	u32 *buf;
 
 	if ((cpu < 0) || (cpu >= NR_CPUS))
@@ -1115,11 +1124,12 @@ void crash_save_cpu(struct pt_regs *regs
 	buf = (u32*)per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
 		return;
-	memset(&prstatus, 0, sizeof(prstatus));
-	prstatus.pr_pid = current->pid;
-	kexec_elf_core_copy_regs(&prstatus.pr_reg, regs);
+	prstatus = &per_cpu(elf_prstatus, cpu);
+	memset(prstatus, 0, sizeof(struct elf_prstatus));
+	prstatus->pr_pid = current->pid;
+	kexec_elf_core_copy_regs(&(prstatus->pr_reg), regs);
 	buf = append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS,
-		      	      &prstatus, sizeof(prstatus));
+			      prstatus, sizeof(struct elf_prstatus));
 	final_note(buf);
 }
 

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

