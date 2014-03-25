From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Tue, 25 Mar 2014 20:57:56 +0000
Subject: [PATCH v3 5/5] xen: Put EFI machinery in place
Message-Id: <1395781076-12000-6-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
In-Reply-To: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com, Daniel Kiper <daniel.kiper@oracle.com>, Tang Liang <liang.tang@oracle.com>

Put EFI machinery for Xen in place.

This patch is based on Jan Beulich and Tang Liang work.

Signed-off-by: Daniel Kiper <daniel.kiper@oracle.com>
Signed-off-by: Tang Liang <liang.tang@oracle.com>
Signed-off-by: Jan Beulich <jbeulich@suse.com>
---
 arch/x86/xen/enlighten.c |   10 ++
 drivers/xen/Kconfig      |    3 +
 drivers/xen/Makefile     |    1 +
 drivers/xen/efi.c        |  425 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 439 insertions(+)
 create mode 100644 drivers/xen/efi.c

diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 201d09a..38bdb96 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -150,6 +150,14 @@ struct shared_info *HYPERVISOR_shared_info = &xen_dummy_shared_info;
  */
 static int have_vcpu_info_placement = 1;
 
+#ifdef CONFIG_XEN_EFI
+extern void __init xen_efi_probe(void);
+#else
+static void __init xen_efi_probe(void)
+{
+}
+#endif
+
 struct tls_descs {
 	struct desc_struct desc[3];
 };
@@ -1714,6 +1722,8 @@ asmlinkage void __init xen_start_kernel(void)
 
 	xen_setup_runstate_info(0);
 
+	xen_efi_probe();
+
 	/* Start the world */
 #ifdef CONFIG_X86_32
 	i386_start_kernel();
diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 38fb36e..cead283 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -240,4 +240,7 @@ config XEN_MCE_LOG
 config XEN_HAVE_PVMMU
        bool
 
+config XEN_EFI
+	def_bool X86_64 && EFI
+
 endmenu
diff --git a/drivers/xen/Makefile b/drivers/xen/Makefile
index 45e00af..c35de02 100644
--- a/drivers/xen/Makefile
+++ b/drivers/xen/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_XEN_STUB)			+= xen-stub.o
 obj-$(CONFIG_XEN_ACPI_HOTPLUG_MEMORY)	+= xen-acpi-memhotplug.o
 obj-$(CONFIG_XEN_ACPI_HOTPLUG_CPU)	+= xen-acpi-cpuhotplug.o
 obj-$(CONFIG_XEN_ACPI_PROCESSOR)	+= xen-acpi-processor.o
+obj-$(CONFIG_XEN_EFI)			+= efi.o
 xen-evtchn-y				:= evtchn.o
 xen-gntdev-y				:= gntdev.o
 xen-gntalloc-y				:= gntalloc.o
diff --git a/drivers/xen/efi.c b/drivers/xen/efi.c
new file mode 100644
index 0000000..f3768e7
--- /dev/null
+++ b/drivers/xen/efi.c
@@ -0,0 +1,425 @@
+/*
+ * EFI support for Xen.
+ *
+ * Copyright (C) 1999 VA Linux Systems
+ * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 1999-2002 Hewlett-Packard Co.
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ *	Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2005-2008 Intel Co.
+ *	Fenghua Yu <fenghua.yu@intel.com>
+ *	Bibo Mao <bibo.mao@intel.com>
+ *	Chandramouli Narayanan <mouli@linux.intel.com>
+ *	Huang Ying <ying.huang@intel.com>
+ * Copyright (C) 2011 Novell Co.
+ *	Jan Beulic <JBeulich@suse.com>
+ * Copyright (C) 2011-2012 Oracle Co.
+ *	Liang Tang <liang.tang@oracle.com>
+ * Copyright (c) 2014 Daniel Kiper, Oracle Corporation
+ */
+
+#include <linux/efi.h>
+#include <linux/export.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/platform_device.h>
+#include <linux/time.h>
+#include <linux/spinlock.h>
+
+#include <asm/cacheflush.h>
+#include <asm/efi.h>
+#include <asm/tlbflush.h>
+#include <asm/setup.h>
+
+#include <xen/interface/platform.h>
+#include <asm/xen/hypercall.h>
+
+#define PFX		"EFI: "
+
+#define call (op.u.efi_runtime_call)
+#define DECLARE_CALL(what) \
+	struct xen_platform_op op; \
+	op.cmd = XENPF_efi_runtime_call; \
+	call.function = XEN_EFI_##what; \
+	call.misc = 0
+
+static efi_status_t xen_efi_get_time(efi_time_t *tm, efi_time_cap_t *tc)
+{
+	int err;
+	DECLARE_CALL(get_time);
+
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	if (tm) {
+		BUILD_BUG_ON(sizeof(*tm) != sizeof(call.u.get_time.time));
+		memcpy(tm, &call.u.get_time.time, sizeof(*tm));
+	}
+
+	if (tc) {
+		tc->resolution = call.u.get_time.resolution;
+		tc->accuracy = call.u.get_time.accuracy;
+		tc->sets_to_zero = !!(call.misc &
+				      XEN_EFI_GET_TIME_SET_CLEARS_NS);
+	}
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_set_time(efi_time_t *tm)
+{
+	DECLARE_CALL(set_time);
+
+	BUILD_BUG_ON(sizeof(*tm) != sizeof(call.u.set_time));
+	memcpy(&call.u.set_time, tm, sizeof(*tm));
+
+	return HYPERVISOR_dom0_op(&op) ? EFI_UNSUPPORTED : call.status;
+}
+
+static efi_status_t xen_efi_get_wakeup_time(efi_bool_t *enabled,
+					    efi_bool_t *pending,
+					    efi_time_t *tm)
+{
+	int err;
+	DECLARE_CALL(get_wakeup_time);
+
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	if (tm) {
+		BUILD_BUG_ON(sizeof(*tm) != sizeof(call.u.get_wakeup_time));
+		memcpy(tm, &call.u.get_wakeup_time, sizeof(*tm));
+	}
+
+	if (enabled)
+		*enabled = !!(call.misc & XEN_EFI_GET_WAKEUP_TIME_ENABLED);
+
+	if (pending)
+		*pending = !!(call.misc & XEN_EFI_GET_WAKEUP_TIME_PENDING);
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_set_wakeup_time(efi_bool_t enabled, efi_time_t *tm)
+{
+	DECLARE_CALL(set_wakeup_time);
+
+	BUILD_BUG_ON(sizeof(*tm) != sizeof(call.u.set_wakeup_time));
+	if (enabled)
+		call.misc = XEN_EFI_SET_WAKEUP_TIME_ENABLE;
+	if (tm)
+		memcpy(&call.u.set_wakeup_time, tm, sizeof(*tm));
+	else
+		call.misc |= XEN_EFI_SET_WAKEUP_TIME_ENABLE_ONLY;
+
+	return HYPERVISOR_dom0_op(&op) ? EFI_UNSUPPORTED : call.status;
+}
+
+static efi_status_t xen_efi_get_variable(efi_char16_t *name,
+					 efi_guid_t *vendor,
+					 u32 *attr,
+					 unsigned long *data_size,
+					 void *data)
+{
+	int err;
+	DECLARE_CALL(get_variable);
+
+	set_xen_guest_handle(call.u.get_variable.name, name);
+	BUILD_BUG_ON(sizeof(*vendor) !+		     sizeof(call.u.get_variable.vendor_guid));
+	memcpy(&call.u.get_variable.vendor_guid, vendor, sizeof(*vendor));
+	call.u.get_variable.size = *data_size;
+	set_xen_guest_handle(call.u.get_variable.data, data);
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	*data_size = call.u.get_variable.size;
+	*attr = call.misc; /* misc in struction is U32 variable*/
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_get_next_variable(unsigned long *name_size,
+					      efi_char16_t *name,
+					      efi_guid_t *vendor)
+{
+	int err;
+	DECLARE_CALL(get_next_variable_name);
+	if (efi.runtime_version < EFI_2_00_SYSTEM_TABLE_REVISION)
+		return EFI_UNSUPPORTED;
+	call.u.get_next_variable_name.size = *name_size;
+	set_xen_guest_handle(call.u.get_next_variable_name.name, name);
+	BUILD_BUG_ON(sizeof(*vendor) !+		     sizeof(call.u.get_next_variable_name.vendor_guid));
+	memcpy(&call.u.get_next_variable_name.vendor_guid, vendor,
+	       sizeof(*vendor));
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	*name_size = call.u.get_next_variable_name.size;
+	memcpy(vendor, &call.u.get_next_variable_name.vendor_guid,
+	       sizeof(*vendor));
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_set_variable(efi_char16_t *name,
+					 efi_guid_t *vendor,
+					 u32 attr,
+					 unsigned long data_size,
+					 void *data)
+{
+	DECLARE_CALL(set_variable);
+
+	set_xen_guest_handle(call.u.set_variable.name, name);
+	call.misc = attr;
+	BUILD_BUG_ON(sizeof(*vendor) !+		     sizeof(call.u.set_variable.vendor_guid));
+	memcpy(&call.u.set_variable.vendor_guid, vendor, sizeof(*vendor));
+	call.u.set_variable.size = data_size;
+	set_xen_guest_handle(call.u.set_variable.data, data);
+
+	return HYPERVISOR_dom0_op(&op) ? EFI_UNSUPPORTED : call.status;
+}
+
+static efi_status_t xen_efi_query_variable_info(u32 attr,
+						u64 *storage_space,
+						u64 *remaining_space,
+						u64 *max_variable_size)
+{
+	int err;
+	DECLARE_CALL(query_variable_info);
+
+	if (efi.runtime_version < EFI_2_00_SYSTEM_TABLE_REVISION)
+		return EFI_UNSUPPORTED;
+
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	*storage_space = call.u.query_variable_info.max_store_size;
+	*remaining_space = call.u.query_variable_info.remain_store_size;
+	*max_variable_size = call.u.query_variable_info.max_size;
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_get_next_high_mono_count(u32 *count)
+{
+	int err;
+	DECLARE_CALL(get_next_high_monotonic_count);
+
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	*count = call.misc;
+
+	return call.status;
+}
+
+static efi_status_t xen_efi_update_capsule(efi_capsule_header_t **capsules,
+					   unsigned long count,
+					   unsigned long sg_list)
+{
+	DECLARE_CALL(update_capsule);
+
+	if (efi.runtime_version < EFI_2_00_SYSTEM_TABLE_REVISION)
+		return EFI_UNSUPPORTED;
+
+	set_xen_guest_handle(call.u.update_capsule.capsule_header_array,
+			     capsules);
+	call.u.update_capsule.capsule_count = count;
+	call.u.update_capsule.sg_list = sg_list;
+
+	return HYPERVISOR_dom0_op(&op) ? EFI_UNSUPPORTED : call.status;
+}
+
+static efi_status_t xen_efi_query_capsule_caps(efi_capsule_header_t **capsules,
+					       unsigned long count,
+					       u64 *max_size,
+					       int *reset_type)
+{
+	int err;
+	DECLARE_CALL(query_capsule_capabilities);
+
+	if (efi.runtime_version < EFI_2_00_SYSTEM_TABLE_REVISION)
+		return EFI_UNSUPPORTED;
+
+	set_xen_guest_handle(call.u.query_capsule_capabilities.
+		capsule_header_array, capsules);
+	call.u.query_capsule_capabilities.capsule_count = count;
+
+	err = HYPERVISOR_dom0_op(&op);
+	if (err)
+		return EFI_UNSUPPORTED;
+
+	*max_size = call.u.query_capsule_capabilities.max_capsule_size;
+	*reset_type = call.u.query_capsule_capabilities.reset_type;
+
+	return call.status;
+}
+
+#undef DECLARE_CALL
+#undef call
+
+static efi_system_table_t efi_systab __initdata = {};
+
+static const struct efi efi_xen __initconst = {
+	.systab                   = &efi_systab,
+	.mps                      = EFI_INVALID_TABLE_ADDR,
+	.acpi                     = EFI_INVALID_TABLE_ADDR,
+	.acpi20                   = EFI_INVALID_TABLE_ADDR,
+	.smbios                   = EFI_INVALID_TABLE_ADDR,
+	.sal_systab               = EFI_INVALID_TABLE_ADDR,
+	.boot_info                = EFI_INVALID_TABLE_ADDR,
+	.hcdp                     = EFI_INVALID_TABLE_ADDR,
+	.uga                      = EFI_INVALID_TABLE_ADDR,
+	.uv_systab                = EFI_INVALID_TABLE_ADDR,
+	.fw_vendor                = EFI_INVALID_TABLE_ADDR,
+	.runtime                  = EFI_INVALID_TABLE_ADDR,
+	.config_table             = EFI_INVALID_TABLE_ADDR,
+	.get_time                 = xen_efi_get_time,
+	.set_time                 = xen_efi_set_time,
+	.get_wakeup_time          = xen_efi_get_wakeup_time,
+	.set_wakeup_time          = xen_efi_set_wakeup_time,
+	.get_variable             = xen_efi_get_variable,
+	.get_next_variable        = xen_efi_get_next_variable,
+	.set_variable             = xen_efi_set_variable,
+	.query_variable_info      = xen_efi_query_variable_info,
+	.update_capsule           = xen_efi_update_capsule,
+	.query_capsule_caps       = xen_efi_query_capsule_caps,
+	.get_next_high_mono_count = xen_efi_get_next_high_mono_count,
+	.reset_system             = NULL, /* Functionality provided by Xen. */
+	.set_virtual_address_map  = NULL, /* Not used under Xen. */
+	.memmap                   = NULL  /* Not used under Xen. */
+};
+
+static void __init efi_init_xen(void)
+{
+	efi_char16_t vendor_c16[100];
+	char vendor[ARRAY_SIZE(vendor_c16)];
+	int ret, i;
+	struct xen_platform_op op;
+	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
+
+	efi = efi_xen;
+	op.cmd = XENPF_firmware_info;
+	op.u.firmware_info.type = XEN_FW_EFI_INFO;
+
+	/*
+	 * Show what we know for posterity
+	 */
+	op.u.firmware_info.index = XEN_FW_EFI_VENDOR;
+	info->vendor.bufsz = sizeof(vendor_c16);
+	set_xen_guest_handle(info->vendor.name, vendor_c16);
+	ret = HYPERVISOR_dom0_op(&op);
+	if (!ret) {
+		for (i = 0; i < sizeof(vendor) - 1 && vendor_c16[i]; ++i)
+			vendor[i] = vendor_c16[i];
+		vendor[i] = '\0';
+	} else
+		pr_err("Could not get the firmware vendor!\n");
+
+	op.u.firmware_info.index = XEN_FW_EFI_VERSION;
+	ret = HYPERVISOR_dom0_op(&op);
+	if (!ret)
+		pr_info("EFI v%u.%.02u by %s\n",
+		       info->version >> 16,
+		       info->version & 0xffff, vendor);
+	else
+		pr_err("Could not get EFI revision!\n");
+
+	op.u.firmware_info.index = XEN_FW_EFI_RT_VERSION;
+	ret = HYPERVISOR_dom0_op(&op);
+	if (!ret)
+		efi.runtime_version = info->version;
+	else
+		pr_warn(PFX "Could not get runtime services revision.\n");
+
+	/*
+	 * Let's see what config tables the firmware passed to us.
+	 */
+	op.u.firmware_info.index = XEN_FW_EFI_CONFIG_TABLE;
+	if (HYPERVISOR_dom0_op(&op))
+		BUG();
+
+	efi.systab->tables = info->cfg.addr;
+	efi.systab->nr_tables = info->cfg.nent;
+
+	if (efi_config_init(arch_tables))
+		return;
+
+	set_bit(EFI_CONFIG_TABLES, &x86_efi_facility);
+
+	x86_platform.get_wallclock = efi_get_time;
+	x86_platform.set_wallclock = efi_set_rtc_mmss;
+
+	set_bit(EFI_RUNTIME_SERVICES, &x86_efi_facility);
+}
+
+static void __init efi_reserve_boot_services_xen(void)
+{
+}
+
+static void __init efi_enter_virtual_mode_xen(void)
+{
+}
+
+/*
+ * Convenience functions to obtain memory types and attributes
+ */
+static u32 efi_mem_type_xen(unsigned long phys_addr)
+{
+	struct xen_platform_op op;
+	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
+
+	op.cmd = XENPF_firmware_info;
+	op.u.firmware_info.type = XEN_FW_EFI_INFO;
+	op.u.firmware_info.index = XEN_FW_EFI_MEM_INFO;
+	info->mem.addr = phys_addr;
+	info->mem.size = 0;
+	return HYPERVISOR_dom0_op(&op) ? 0 : info->mem.type;
+}
+
+static u64 efi_mem_attributes_xen(unsigned long phys_addr)
+{
+	struct xen_platform_op op;
+	union xenpf_efi_info *info = &op.u.firmware_info.u.efi_info;
+
+	op.cmd = XENPF_firmware_info;
+	op.u.firmware_info.type = XEN_FW_EFI_INFO;
+	op.u.firmware_info.index = XEN_FW_EFI_MEM_INFO;
+	info->mem.addr = phys_addr;
+	info->mem.size = 0;
+	return HYPERVISOR_dom0_op(&op) ? 0 : info->mem.attr;
+}
+
+void __init xen_efi_probe(void)
+{
+	struct xen_platform_op op = {
+		.cmd = XENPF_firmware_info,
+		.u.firmware_info = {
+			.type = XEN_FW_EFI_INFO,
+			.index = XEN_FW_EFI_CONFIG_TABLE
+		}
+	};
+
+	if (!xen_initial_domain() || HYPERVISOR_dom0_op(&op))
+		return;
+
+	/* Here we know that Xen runs on EFI platform. */
+
+	efi_init_ops.efi_init = efi_init_xen;
+	efi_init_ops.efi_reserve_boot_services = efi_reserve_boot_services_xen;
+	efi_init_ops.efi_enter_virtual_mode = efi_enter_virtual_mode_xen;
+	efi_init_ops.efi_mem_type = efi_mem_type_xen;
+	efi_init_ops.efi_mem_attributes = efi_mem_attributes_xen;
+
+	set_bit(EFI_BOOT, &x86_efi_facility);
+	set_bit(EFI_64BIT, &x86_efi_facility);
+}
-- 
1.7.10.4

