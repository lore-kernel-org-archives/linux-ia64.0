From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 13 Oct 2006 17:05:45 +0000
Subject: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <000101c6eee9$d2ee96c0$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

It's not efficient to use a per-cpu variable just to store
how many physical stack register a cpu has.  Ever since the
incarnation of ia64 up till upcoming Montecito processor, that
variable has "glued" to 96. Having a variable in memory means
that the kernel is burning an extra cacheline access on every
syscall and kernel exit path.  Such "static" value is better
served with the instruction patching utility exists today.
Convert ia64_phys_stacked_size_p8 into dynamic insn patching.

This also has a pleasant side effect of eliminating access to
per-cpu area while psr.ic=3D0 in the kernel exit path. (fixable
for per-cpu DTC work, but why bother?)

There are some concerns with the default value that the instruc-
tion encoded in the kernel image.  It shouldn't be concerned.
The reasons are:

(1) cpu_init() is called at CPU initialization.  In there, we
    find out physical stack register size from PAL and patch
    two instructions in kernel exit code.  The code in question
    can not be executed before the patching is done.

(2) current implementation stores zero in ia64_phys_stacked_size_p8,
    and that's what the current kernel exit path loads the value with.
    With the new code, it is equivalent that we store reg size 96
    in ia64_phys_stacked_size_p8, thus creating a better safety net.
    Given (1) above can never fail, having (2) is just a bonus.

All in all, this patch allow one less memory reference in the kernel
exit path, thus reducing syscall and interrupt return latency; and
avoid polluting potential useful data in the CPU cache.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/patch.h.orig	2006-10-10 19:51:20.000000000 -0700
+++ ./include/asm-ia64/patch.h	2006-10-13 10:35:30.000000000 -0700
@@ -20,6 +20,7 @@ extern void ia64_patch_imm60 (u64 insn_a
=20
 extern void ia64_patch_mckinley_e9 (unsigned long start, unsigned long end=
);
 extern void ia64_patch_vtop (unsigned long start, unsigned long end);
+extern void ia64_patch_phys_stack_reg(unsigned long val);
 extern void ia64_patch_gate (void);
=20
 #endif /* _ASM_IA64_PATCH_H */
--- ./include/asm-ia64/sections.h.orig	2006-10-10 19:51:20.000000000 -0700
+++ ./include/asm-ia64/sections.h	2006-10-13 10:35:30.000000000 -0700
@@ -11,6 +11,7 @@
 extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
 extern char __start___vtop_patchlist[], __end___vtop_patchlist[];
 extern char __start___mckinley_e9_bundles[], __end___mckinley_e9_bundles[];
+extern char __start___phys_stack_reg_patchlist[], __end___phys_stack_reg_p=
atchlist[];
 extern char __start_gate_section[];
 extern char __start_gate_mckinley_e9_patchlist[], __end_gate_mckinley_e9_p=
atchlist[];
 extern char __start_gate_vtop_patchlist[], __end_gate_vtop_patchlist[];
--- ./include/asm-ia64/asmmacro.h.orig	2006-10-10 19:51:20.000000000 -0700
+++ ./include/asm-ia64/asmmacro.h	2006-10-13 10:35:30.000000000 -0700
@@ -104,6 +104,16 @@ name:
 #endif
=20
 /*
+ * If physical stack register size is different from DEF_NUM_STACK_REG,
+ * dynamically patch the kernel for correct size.
+ */
+	.section ".data.patch.phys_stack_reg", "a"
+	.previous
+#define LOAD_PHYS_STACK_REG_SIZE(reg)			\
+[1:]	adds reg=3DIA64_NUM_PHYS_STACK_REG*8+8,r0;	\
+	.xdata4 ".data.patch.phys_stack_reg", 1b-.
+
+/*
  * Up until early 2004, use of .align within a function caused bad unwind =
info.
  * TEXT_ALIGN(n) expands into ".align n" if a fixed GAS is available or in=
to nothing
  * otherwise.
--- ./include/asm-ia64/processor.h.orig	2006-10-10 19:51:20.000000000 -0700
+++ ./include/asm-ia64/processor.h	2006-10-13 10:35:30.000000000 -0700
@@ -19,6 +19,7 @@
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
=20
+#define IA64_NUM_PHYS_STACK_REG	96
 #define IA64_NUM_DBG_REGS	8
=20
 #define DEFAULT_MAP_BASE	__IA64_UL_CONST(0x2000000000000000)
--- ./arch/ia64/kernel/setup.c.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/kernel/setup.c	2006-10-13 10:41:50.000000000 -0700
@@ -73,7 +73,6 @@ extern void ia64_setup_printk_clock(void
=20
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
-DEFINE_PER_CPU(unsigned long, ia64_phys_stacked_size_p8);
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
 struct screen_info screen_info;
@@ -775,6 +774,7 @@ void __cpuinit
 cpu_init (void)
 {
 	extern void __cpuinit ia64_mmu_init (void *);
+	static unsigned long max_num_phys_stacked =3D IA64_NUM_PHYS_STACK_REG;
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
@@ -888,7 +888,10 @@ cpu_init (void)
 		num_phys_stacked =3D 96;
 	}
 	/* size of physical stacked register partition plus 8 bytes: */
-	__get_cpu_var(ia64_phys_stacked_size_p8) =3D num_phys_stacked*8 + 8;
+	if (num_phys_stacked > max_num_phys_stacked) {
+		ia64_patch_phys_stack_reg(num_phys_stacked*8 + 8);
+		max_num_phys_stacked =3D num_phys_stacked;
+	}
 	platform_cpu_init();
 	pm_idle =3D default_idle;
 }
--- ./arch/ia64/kernel/vmlinux.lds.S.orig	2006-10-10 19:51:10.000000000 -07=
00
+++ ./arch/ia64/kernel/vmlinux.lds.S	2006-10-13 10:35:30.000000000 -0700
@@ -78,6 +78,13 @@ SECTIONS
 	  __stop___mca_table =3D .;
 	}
=20
+  .data.patch.phys_stack_reg : AT(ADDR(.data.patch.phys_stack_reg) - LOAD_=
OFFSET)
+	{
+	  __start___phys_stack_reg_patchlist =3D .;
+	  *(.data.patch.phys_stack_reg)
+	  __end___phys_stack_reg_patchlist =3D .;
+	}
+
   /* Global data */
   _data =3D .;
=20
--- ./arch/ia64/kernel/entry.S.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/kernel/entry.S	2006-10-13 10:35:30.000000000 -0700
@@ -767,7 +767,7 @@ ENTRY(ia64_leave_syscall)
 	ld8.fill r15=3D[r3]			// M0|1 restore r15
 	mov b6=3Dr18				// I0   restore b6
=20
-	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0 // A
+	LOAD_PHYS_STACK_REG_SIZE(r17)
 	mov f9=F0					// F    clear f9
 (pKStk) br.cond.dpnt.many skip_rbs_switch		// B
=20
@@ -775,7 +775,6 @@ ENTRY(ia64_leave_syscall)
 	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
 	cover				// B    add current frame into dirty partition & set cr.ifs
 	;;
-(pUStk) ld4 r17=3D[r17]			// M0|1 r17 =3D cpu_data->phys_stacked_size_p8
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
 	mov f10=F0			// F    clear f10
=20
@@ -953,9 +952,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=3Dar.bsp		// get existing backing store pointer
-	addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
-	;;
-	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
+	LOAD_PHYS_STACK_REG_SIZE(r17)
 (pKStk)	br.cond.dpnt skip_rbs_switch
=20
 	/*
--- ./arch/ia64/kernel/patch.c.orig	2006-10-10 19:51:10.000000000 -0700
+++ ./arch/ia64/kernel/patch.c	2006-10-13 10:35:30.000000000 -0700
@@ -195,3 +195,23 @@ ia64_patch_gate (void)
 	ia64_patch_vtop(START(vtop), END(vtop));
 	ia64_patch_mckinley_e9(START(mckinley_e9), END(mckinley_e9));
 }
+
+void ia64_patch_phys_stack_reg(unsigned long val)
+{
+	s32 * offp =3D (s32 *) __start___phys_stack_reg_patchlist;
+	s32 * end =3D (s32 *) __end___phys_stack_reg_patchlist;
+	u64 ip, mask, imm;
+
+	/* see instruction format A4: adds r1 =3D imm13, r3 */
+	mask =3D (0x3fUL << 27) | (0x7f << 13);
+	imm =3D (((val >> 7) & 0x3f) << 27) | (val & 0x7f) << 13;
+
+	while (offp < end) {
+		ip =3D (u64) offp + *offp;
+		ia64_patch(ip, mask, imm);
+		ia64_fc(ip);
+		++offp;
+	}
+	ia64_sync_i();
+	ia64_srlz_i();
+}
