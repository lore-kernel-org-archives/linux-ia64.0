From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 15 Dec 2011 03:29:53 +0000
Subject: [PATCH 11/15] module_param: make bool parameters really bool (arch)
Message-Id: <87hb12seu6.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Pawel Moll <pawel.moll@arm.com>

module_param(bool) used to counter-intuitively take an int.  In
fddd5201 (mid-2009) we allowed bool or int/unsigned int using a messy
trick.

It's time to remove the int/unsigned int option.  For this version
it'll simply give a warning, but it'll break next kernel version.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 arch/ia64/hp/common/aml_nfw.c  |    2 +-
 arch/x86/kernel/apm_32.c       |   16 ++++++++--------
 arch/x86/kvm/mmu.c             |    4 ++--
 arch/x86/kvm/vmx.c             |   18 +++++++++---------
 arch/x86/kvm/x86.c             |    4 ++--
 arch/x86/mm/mmio-mod.c         |    4 ++--
 arch/x86/platform/geode/alix.c |    2 +-
 arch/x86/platform/iris/iris.c  |    2 +-
 8 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/hp/common/aml_nfw.c b/arch/ia64/hp/common/aml_nfw.c
--- a/arch/ia64/hp/common/aml_nfw.c
+++ b/arch/ia64/hp/common/aml_nfw.c
@@ -31,7 +31,7 @@ MODULE_AUTHOR("Bjorn Helgaas <bjorn.helg
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("ACPI opregion handler for native firmware calls");
=20
-static int force_register;
+static bool force_register;
 module_param_named(force, force_register, bool, 0);
 MODULE_PARM_DESC(force, "Install opregion handler even without HPQ5001 dev=
ice");
=20
diff --git a/arch/x86/kernel/apm_32.c b/arch/x86/kernel/apm_32.c
--- a/arch/x86/kernel/apm_32.c
+++ b/arch/x86/kernel/apm_32.c
@@ -383,21 +383,21 @@ static int ignore_sys_suspend;
 static int ignore_normal_resume;
 static int bounce_interval __read_mostly =3D DEFAULT_BOUNCE_INTERVAL;
=20
-static int debug __read_mostly;
+static bool debug __read_mostly;
 static int smp __read_mostly;
 static int apm_disabled =3D -1;
 #ifdef CONFIG_SMP
-static int power_off;
+static bool power_off;
 #else
-static int power_off =3D 1;
+static bool power_off =3D 1;
 #endif
-static int realmode_power_off;
+static bool realmode_power_off;
 #ifdef CONFIG_APM_ALLOW_INTS
-static int allow_ints =3D 1;
+static bool allow_ints =3D 1;
 #else
-static int allow_ints;
+static bool allow_ints;
 #endif
-static int broken_psr;
+static bool broken_psr;
=20
 static DECLARE_WAIT_QUEUE_HEAD(apm_waitqueue);
 static DECLARE_WAIT_QUEUE_HEAD(apm_suspend_waitqueue);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -83,11 +83,11 @@ char *audit_point_name[] =3D {
 #endif
=20
 #ifdef MMU_DEBUG
-static int dbg =3D 0;
+static bool dbg =3D 0;
 module_param(dbg, bool, 0644);
 #endif
=20
-static int oos_shadow =3D 1;
+static bool oos_shadow =3D 1;
 module_param(oos_shadow, bool, 0644);
=20
 #ifndef MMU_DEBUG
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -50,29 +50,29 @@
 MODULE_AUTHOR("Qumranet");
 MODULE_LICENSE("GPL");
=20
-static int __read_mostly enable_vpid =3D 1;
+static bool __read_mostly enable_vpid =3D 1;
 module_param_named(vpid, enable_vpid, bool, 0444);
=20
-static int __read_mostly flexpriority_enabled =3D 1;
+static bool __read_mostly flexpriority_enabled =3D 1;
 module_param_named(flexpriority, flexpriority_enabled, bool, S_IRUGO);
=20
-static int __read_mostly enable_ept =3D 1;
+static bool __read_mostly enable_ept =3D 1;
 module_param_named(ept, enable_ept, bool, S_IRUGO);
=20
-static int __read_mostly enable_unrestricted_guest =3D 1;
+static bool __read_mostly enable_unrestricted_guest =3D 1;
 module_param_named(unrestricted_guest,
 			enable_unrestricted_guest, bool, S_IRUGO);
=20
-static int __read_mostly emulate_invalid_guest_state =3D 0;
+static bool __read_mostly emulate_invalid_guest_state =3D 0;
 module_param(emulate_invalid_guest_state, bool, S_IRUGO);
=20
-static int __read_mostly vmm_exclusive =3D 1;
+static bool __read_mostly vmm_exclusive =3D 1;
 module_param(vmm_exclusive, bool, S_IRUGO);
=20
-static int __read_mostly yield_on_hlt =3D 1;
+static bool __read_mostly yield_on_hlt =3D 1;
 module_param(yield_on_hlt, bool, S_IRUGO);
=20
-static int __read_mostly fasteoi =3D 1;
+static bool __read_mostly fasteoi =3D 1;
 module_param(fasteoi, bool, S_IRUGO);
=20
 /*
@@ -80,7 +80,7 @@ module_param(fasteoi, bool, S_IRUGO);
  * VMX and be a hypervisor for its own guests. If nested=3D0, guests may n=
ot
  * use VMX instructions.
  */
-static int __read_mostly nested =3D 0;
+static bool __read_mostly nested =3D 0;
 module_param(nested, bool, S_IRUGO);
=20
 #define KVM_GUEST_CR0_MASK_UNRESTRICTED_GUEST				\
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -89,8 +89,8 @@ static void process_nmi(struct kvm_vcpu=20
 struct kvm_x86_ops *kvm_x86_ops;
 EXPORT_SYMBOL_GPL(kvm_x86_ops);
=20
-int ignore_msrs =3D 0;
-module_param_named(ignore_msrs, ignore_msrs, bool, S_IRUGO | S_IWUSR);
+static bool ignore_msrs =3D 0;
+module_param(ignore_msrs, bool, S_IRUGO | S_IWUSR);
=20
 bool kvm_has_tsc_control;
 EXPORT_SYMBOL_GPL(kvm_has_tsc_control);
diff --git a/arch/x86/mm/mmio-mod.c b/arch/x86/mm/mmio-mod.c
--- a/arch/x86/mm/mmio-mod.c
+++ b/arch/x86/mm/mmio-mod.c
@@ -75,8 +75,8 @@ static LIST_HEAD(trace_list);		/* struct
=20
 /* module parameters */
 static unsigned long	filter_offset;
-static int		nommiotrace;
-static int		trace_pc;
+static bool		nommiotrace;
+static bool		trace_pc;
=20
 module_param(filter_offset, ulong, 0);
 module_param(nommiotrace, bool, 0);
diff --git a/arch/x86/platform/geode/alix.c b/arch/x86/platform/geode/alix.c
--- a/arch/x86/platform/geode/alix.c
+++ b/arch/x86/platform/geode/alix.c
@@ -27,7 +27,7 @@
=20
 #include <asm/geode.h>
=20
-static int force =3D 0;
+static bool force =3D 0;
 module_param(force, bool, 0444);
 /* FIXME: Award bios is not automatically detected as Alix platform */
 MODULE_PARM_DESC(force, "Force detection as ALIX.2/ALIX.3 platform");
diff --git a/arch/x86/kernel/apm_32.c b/arch/x86/kernel/apm_32.c
--- a/arch/x86/kernel/apm_32.c
+++ b/arch/x86/kernel/apm_32.c
@@ -384,7 +384,7 @@ static int ignore_normal_resume;
 static int bounce_interval __read_mostly =3D DEFAULT_BOUNCE_INTERVAL;
=20
 static bool debug __read_mostly;
-static int smp __read_mostly;
+static bool smp __read_mostly;
 static int apm_disabled =3D -1;
 #ifdef CONFIG_SMP
 static bool power_off;
diff --git a/arch/x86/platform/iris/iris.c b/arch/x86/platform/iris/iris.c
--- a/arch/x86/platform/iris/iris.c
+++ b/arch/x86/platform/iris/iris.c
@@ -42,7 +42,7 @@ MODULE_AUTHOR("S=C3=A9bastien Hinderer <Seba
 MODULE_DESCRIPTION("A power_off handler for Iris devices from EuroBraille"=
);
 MODULE_SUPPORTED_DEVICE("Eurobraille/Iris");
=20
-static int force;
+static bool force;
=20
 module_param(force, bool, 0);
 MODULE_PARM_DESC(force, "Set to one to force poweroff handler installation=
.");
