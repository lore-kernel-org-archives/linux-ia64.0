From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Sep 2008 23:42:52 +0000
Subject: RE: kdump broken on Altix 350
Message-Id: <200809292342.m8TNgq4u004680@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA34DB4172D@orsmsx505.amr.corp.intel.com>
References: <20080829180302.6e67c26e@halley.suse.de>
In-Reply-To: <20080829180302.6e67c26e@halley.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jay Lan <jlan@sgi.com>
Cc: "kexec@lists.infradead.org" <kexec@lists.infradead.org>, Bernhard Walle <bwalle@suse.de>, Simon Horman <horms@verge.net.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Does this make kexec/kdump happier?  Bare minimum testing so far
(builds and boots on tiger ... didn't try kexec yet).



[IA64] Put the space for cpu0 per-cpu area into .data section

Initial fix for making sure that we can access percpu variables
in all C code commit: 10617bbe84628eb18ab5f723d3ba35005adde143
inadvertantly allocated the memory in the "percpu" section of
the vmlinux ELF executable.  This confused kexec.

Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/include/asm/sections.h b/arch/ia64/include/asm/sections.h
index f667998..1a873b3 100644
--- a/arch/ia64/include/asm/sections.h
+++ b/arch/ia64/include/asm/sections.h
@@ -11,6 +11,9 @@
 #include <asm-generic/sections.h>
 
 extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
+#ifdef	CONFIG_SMP
+extern char __cpu0_per_cpu[];
+#endif
 extern char __start___vtop_patchlist[], __end___vtop_patchlist[];
 extern char __start___rse_patchlist[], __end___rse_patchlist[];
 extern char __start___mckinley_e9_bundles[], __end___mckinley_e9_bundles[];
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 8bdea8e..66e491d 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -367,16 +367,17 @@ start_ap:
 	;;
 #else
 (isAP)	br.few 2f
-	mov r20=r19
-	sub r19=r19,r18
+	movl r20=__cpu0_per_cpu
 	;;
 	shr.u r18=r18,3
 1:
-	ld8 r21=[r20],8;;
-	st8[r19]=r21,8
+	ld8 r21=[r19],8;;
+	st8[r20]=r21,8
 	adds r18=-1,r18;;
 	cmp4.lt p7,p6=0,r18
 (p7)	br.cond.dptk.few 1b
+	mov r19=r20
+	;;
 2:
 #endif
 	tpa r19=r19
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index de71da8..10a7d47 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -215,9 +215,6 @@ SECTIONS
   /* Per-cpu data: */
   percpu : { } :percpu
   . = ALIGN(PERCPU_PAGE_SIZE);
-#ifdef	CONFIG_SMP
-  . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
-#endif
   __phys_per_cpu_start = .;
   .data.percpu PERCPU_ADDR : AT(__phys_per_cpu_start - LOAD_OFFSET)
 	{
@@ -233,6 +230,11 @@ SECTIONS
   data : { } :data
   .data : AT(ADDR(.data) - LOAD_OFFSET)
 	{
+#ifdef	CONFIG_SMP
+  . = ALIGN(PERCPU_PAGE_SIZE);
+		__cpu0_per_cpu = .;
+  . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
+#endif
 		DATA_DATA
 		*(.data1)
 		*(.gnu.linkonce.d*)
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index e566ff4..0ee085e 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -163,7 +163,7 @@ per_cpu_init (void)
 	 * get_zeroed_page().
 	 */
 	if (first_time) {
-		void *cpu0_data = __phys_per_cpu_start - PERCPU_PAGE_SIZE;
+		void *cpu0_data = __cpu0_per_cpu;
 
 		first_time=0;
 
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 78026aa..d8c5fcd 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -144,7 +144,7 @@ static void *per_cpu_node_setup(void *cpu_data, int node)
 
 	for_each_possible_early_cpu(cpu) {
 		if (cpu = 0) {
-			void *cpu0_data = __phys_per_cpu_start - PERCPU_PAGE_SIZE;
+			void *cpu0_data = __cpu0_per_cpu;
 			__per_cpu_offset[cpu] = (char*)cpu0_data -
 				__per_cpu_start;
 		} else if (node = node_cpuid[cpu].nid) {
