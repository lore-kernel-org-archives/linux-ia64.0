From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:33 +0000
Subject: [PATCH 06/17] ia64/pv_ops: add an early setup hook for pv_ops.
Message-Id: <1211202825173-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch adds a setup hook in the very early boot sequence
before start_kernel() to initialize paravirtualization stuff.
The hook will be set by each pv loader code or by using multi entry point.

Signed-off-by: Qing He <qing.he@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/head.S     |   41 +++++++++++++++++++++++++++++++++++++++=
++
 include/asm-ia64/paravirt.h |    3 +++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index ddeab4e..db540e5 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -26,11 +26,14 @@
 #include <asm/mmu_context.h>
 #include <asm/asm-offsets.h>
 #include <asm/pal.h>
+#include <asm/paravirt.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
 #include <asm/mca_asm.h>
+#include <linux/init.h>
+#include <linux/linkage.h>
=20
 #ifdef CONFIG_HOTPLUG_CPU
 #define SAL_PSR_BITS_TO_SET				\
@@ -367,6 +370,44 @@ start_ap:
 	;;
 (isBP)	st8 [r2]=3Dr28		// save the address of the boot param area passed b=
y the bootloader
=20
+#ifdef CONFIG_PARAVIRT
+
+	movl r14=3Dhypervisor_setup_hooks
+	movl r15=3Dhypervisor_type
+	mov r16=3Dnum_hypervisor_hooks
+	;;
+	ld8 r2=3D[r15]
+	;;
+	cmp.ltu p7,p0=3Dr2,r16	// array size check
+	shladd r8=3Dr2,3,r14
+	;;
+(p7)	ld8 r9=3D[r8]
+	;;
+(p7)	mov b1=3Dr9
+(p7)	cmp.ne.unc p7,p0=3Dr9,r0	// no actual branch to NULL
+	;;
+(p7)	br.call.sptk.many rp=B1
+
+	__INITDATA
+
+default_setup_hook =3D 0		// Currently nothing needs to be done.
+
+	.weak xen_setup_hook
+
+	.global hypervisor_type
+hypervisor_type:
+	data8		PARAVIRT_HYPERVISOR_TYPE_DEFAULT
+
+	// must have the same order with PARAVIRT_HYPERVISOR_TYPE_xxx
+
+hypervisor_setup_hooks:
+	data8		default_setup_hook
+	data8		xen_setup_hook
+num_hypervisor_hooks =3D (. - hypervisor_setup_hooks) / 8
+	.previous
+
+#endif
+
 #ifdef CONFIG_SMP
 (isAP)	br.call.sptk.many rp=3Dstart_secondary
 .ret0:
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 26b4334..1032b21 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -26,6 +26,9 @@
=20
 #ifdef CONFIG_PARAVIRT_GUEST
=20
+#define PARAVIRT_HYPERVISOR_TYPE_DEFAULT	0
+#define PARAVIRT_HYPERVISOR_TYPE_XEN		1
+
 #ifndef __ASSEMBLY__
=20
 #include <asm/hw_irq.h>
--=20
1.5.3

