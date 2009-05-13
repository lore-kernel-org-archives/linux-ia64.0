From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 13 May 2009 02:42:26 +0000
Subject: [PATCH] ia64/xen: bug fix when CONFIG_CPU_HOTPLUG=y
Message-Id: <20090513024226.GF22497%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

default_setup_hook and related variables in head.S should be
in __CPUINITDATA instead of __INITDATA.
And related warning fix with section mismatch.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/head.S               |    2 +-
 arch/ia64/kernel/paravirt_patchlist.c |    2 +-
 arch/ia64/kernel/patch.c              |    2 +-
 arch/ia64/xen/irq_xen.c               |    4 ++--
 arch/ia64/xen/time.c                  |    2 +-
 arch/ia64/xen/xen_pv_ops.c            |   12 ++++++------
 arch/ia64/xen/xensetup.S              |    2 ++
 7 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 23f846d..40a9932 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -413,7 +413,7 @@ start_ap:
 	;;
 (p7)	br.call.sptk.many rp=B1
=20
-	__INITDATA
+	__CPUINITDATA
=20
 default_setup_hook =3D 0		// Currently nothing needs to be done.
=20
diff --git a/arch/ia64/kernel/paravirt_patchlist.c b/arch/ia64/kernel/parav=
irt_patchlist.c
index b28082a..1304760 100644
--- a/arch/ia64/kernel/paravirt_patchlist.c
+++ b/arch/ia64/kernel/paravirt_patchlist.c
@@ -40,7 +40,7 @@ extern unsigned long __start_gate_section[];
 	.end_##name##_patchlist =3D					    \
 		(unsigned long)__ia64_native_end_gate_##name##_patchlist
=20
-struct pv_patchdata pv_patchdata __initdata =3D {
+struct pv_patchdata pv_patchdata __cpuinitdata =3D {
 	ASSIGN(fsyscall),
 	ASSIGN(brl_fsys_bubble_down),
 	ASSIGN(vtop),
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 68a1311..e76bc5b 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -172,7 +172,7 @@ ia64_patch_mckinley_e9 (unsigned long start, unsigned l=
ong end)
=20
 extern unsigned long ia64_native_fsyscall_table[NR_syscalls];
 extern char ia64_native_fsys_bubble_down[];
-struct pv_fsys_data pv_fsys_data __initdata =3D {
+struct pv_fsys_data pv_fsys_data __cpuinitdata =3D {
 	.fsyscall_table =3D (unsigned long *)ia64_native_fsyscall_table,
 	.fsys_bubble_down =3D (void *)ia64_native_fsys_bubble_down,
 };
diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
index af93aad..55eec89 100644
--- a/arch/ia64/xen/irq_xen.c
+++ b/arch/ia64/xen/irq_xen.c
@@ -408,7 +408,7 @@ xen_platform_send_ipi(int cpu, int vector, int delivery=
_mode, int redirect)
 	}
 }
=20
-static void __init
+static void __cpuinit
 xen_register_ipi(void)
 {
 #ifdef CONFIG_SMP
@@ -424,7 +424,7 @@ xen_resend_irq(unsigned int vector)
 	(void)resend_irq_on_evtchn(vector);
 }
=20
-const struct pv_irq_ops xen_irq_ops __initdata =3D {
+const struct pv_irq_ops xen_irq_ops __cpuinitdata =3D {
 	.register_ipi =3D xen_register_ipi,
=20
 	.assign_irq_vector =3D xen_assign_irq_vector,
diff --git a/arch/ia64/xen/time.c b/arch/ia64/xen/time.c
index fb83326..2f2a5fc 100644
--- a/arch/ia64/xen/time.c
+++ b/arch/ia64/xen/time.c
@@ -222,7 +222,7 @@ static unsigned long long xen_sched_clock(void)
 	return ret;
 }
=20
-struct pv_time_ops xen_time_ops __initdata =3D {
+struct pv_time_ops xen_time_ops __cpuinitdata =3D {
 	.init_missing_ticks_accounting	=3D xen_init_missing_ticks_accounting,
 	.do_steal_accounting		=3D xen_do_steal_accounting,
 	.clocksource_resume		=3D xen_itc_jitter_data_reset,
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 5e2270a..e0d1431 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -36,7 +36,7 @@
 /*************************************************************************=
**
  * general info
  */
-static struct pv_info xen_info __initdata =3D {
+static struct pv_info xen_info __cpuinitdata =3D {
 	.kernel_rpl =3D 2,	/* or 1: determin at runtime */
 	.paravirt_enabled =3D 1,
 	.name =3D "Xen/ia64",
@@ -47,7 +47,7 @@ static struct pv_info xen_info __initdata =3D {
 #define IA64_RSC_PL_MASK	\
 	(((1UL << IA64_RSC_PL_BIT_SIZE) - 1) << IA64_RSC_PL_SHIFT)
=20
-static void __init
+static void __cpuinit
 xen_info_init(void)
 {
 	/* Xenified Linux/ia64 may run on pl =3D 1 or 2.
@@ -184,7 +184,7 @@ static const struct pv_init_ops xen_init_ops __initcons=
t =3D {
=20
 extern unsigned long xen_fsyscall_table[NR_syscalls];
 extern char xen_fsys_bubble_down[];
-struct pv_fsys_data xen_fsys_data __initdata =3D {
+struct pv_fsys_data xen_fsys_data __cpuinitdata =3D {
 	.fsyscall_table =3D (unsigned long *)xen_fsyscall_table,
 	.fsys_bubble_down =3D (void *)xen_fsys_bubble_down,
 };
@@ -211,7 +211,7 @@ extern unsigned long __xen_start_gate_section[];
 	.end_##name##_patchlist =3D					\
 		(unsigned long)__xen_end_gate_##name##_patchlist
=20
-static struct pv_patchdata xen_patchdata __initdata =3D {
+static struct pv_patchdata xen_patchdata __cpuinitdata =3D {
 	ASSIGN(fsyscall),
 	ASSIGN(brl_fsys_bubble_down),
 	ASSIGN(vtop),
@@ -880,7 +880,7 @@ xen_iosapic_write(char __iomem *iosapic, unsigned int r=
eg, u32 val)
 	HYPERVISOR_physdev_op(PHYSDEVOP_apic_write, &apic_op);
 }
=20
-static struct pv_iosapic_ops xen_iosapic_ops __initdata =3D {
+static struct pv_iosapic_ops xen_iosapic_ops __cpuinitdata =3D {
 	.pcat_compat_init =3D xen_pcat_compat_init,
 	.__get_irq_chip =3D xen_iosapic_get_irq_chip,
=20
@@ -892,7 +892,7 @@ static struct pv_iosapic_ops xen_iosapic_ops __initdata=
 =3D {
  * pv_ops initialization
  */
=20
-void __init
+void __cpuinit
 xen_setup_pv_ops(void)
 {
 	xen_info_init();
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
index aff8346..356bb2f 100644
--- a/arch/ia64/xen/xensetup.S
+++ b/arch/ia64/xen/xensetup.S
@@ -54,6 +54,8 @@ END(startup_xen)
=20
 #define isBP	p3	// are we the Bootstrap Processor?
=20
+	__CPUINIT
+
 GLOBAL_ENTRY(xen_setup_hook)
 	mov r8=3DXEN_PV_DOMAIN_ASM
 (isBP)	movl r9=3Dxen_domain_type;;
--=20
1.6.0.2



--=20
yamahata
