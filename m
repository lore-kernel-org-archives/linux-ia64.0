From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:15 +0000
Subject: [15/17][PATCH] kvm/ia64: Add kvm sal/pal virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF1@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.3E06072B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.3E06072B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From ba064fc79c5d8577543ae6e4a201f622f0c4b777 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:42:18 +0800
Subject: [PATCH] kvm/ia64: Add kvm sal/pal virtulization support.

Some sal/pal calls would be traped to kvm for virtulization
from guest firmware.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/kvm_fw.c |  500
++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 500 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/kvm_fw.c

diff --git a/arch/ia64/kvm/kvm_fw.c b/arch/ia64/kvm/kvm_fw.c
new file mode 100644
index 0000000..077d6e7
--- /dev/null
+++ b/arch/ia64/kvm/kvm_fw.c
@@ -0,0 +1,500 @@
+/*
+ * PAL/SAL call delegation
+ *
+ * Copyright (c) 2004 Li Susie <susie.li@intel.com>
+ * Copyright (c) 2005 Yu Ke <ke.yu@intel.com>
+ * Copyright (c) 2007 Xiantao Zhang <xiantao.zhang@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License
along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ */
+
+#include <linux/kvm_host.h>
+#include <linux/smp.h>
+
+#include "vti.h"
+#include "misc.h"
+
+#include <asm/pal.h>
+#include <asm/sal.h>
+#include <asm/tlb.h>
+
+/*
+ * Handy macros to make sure that the PAL return values start out
+ * as something meaningful.
+ */
+#define INIT_PAL_STATUS_UNIMPLEMENTED(x)		\
+	{						\
+		x.status =3D PAL_STATUS_UNIMPLEMENTED;	\
+		x.v0 =3D 0;				\
+		x.v1 =3D 0;				\
+		x.v2 =3D 0;				\
+	}
+
+#define INIT_PAL_STATUS_SUCCESS(x)			\
+	{						\
+		x.status =3D PAL_STATUS_SUCCESS;		\
+		x.v0 =3D 0;				\
+		x.v1 =3D 0;				\
+		x.v2 =3D 0;				\
+    }
+
+static void kvm_get_pal_call_data(struct kvm_vcpu *vcpu,
+		u64 *gr28, u64 *gr29, u64 *gr30, u64 *gr31) {
+	struct exit_ctl_data *p;
+
+	if (vcpu) {
+		p =3D &vcpu->arch.exit_data;
+		if (p->exit_reason =3D=3D EXIT_REASON_PAL_CALL) {
+			*gr28 =3D p->u.pal_data.gr28;
+			*gr29 =3D p->u.pal_data.gr29;
+			*gr30 =3D p->u.pal_data.gr30;
+			*gr31 =3D p->u.pal_data.gr31;
+			return ;
+		}
+	}
+	printk(KERN_DEBUG"Error occurs in kvm_get_pal_call_data!!\n");
+}
+
+static void set_pal_result(struct kvm_vcpu *vcpu,
+		struct ia64_pal_retval result) {
+
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+	if (p && p->exit_reason =3D=3D EXIT_REASON_PAL_CALL) {
+		p->u.pal_data.ret =3D result;
+		return ;
+	}
+	INIT_PAL_STATUS_UNIMPLEMENTED(p->u.pal_data.ret);
+}
+
+static void set_sal_result(struct kvm_vcpu *vcpu,
+		struct sal_ret_values result) {
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+	if (p && p->exit_reason =3D=3D EXIT_REASON_SAL_CALL) {
+		p->u.sal_data.ret =3D result;
+		return ;
+	}
+	printk(KERN_WARNING"Error occurs!!!\n");
+}
+
+struct cache_flush_args {
+	u64 cache_type;
+	u64 operation;
+	u64 progress;
+	long status;
+};
+
+cpumask_t cpu_cache_coherent_map;
+
+static void remote_pal_cache_flush(void *data)
+{
+	struct cache_flush_args *args =3D data;
+	long status;
+	u64 progress =3D args->progress;
+
+	status =3D ia64_pal_cache_flush(args->cache_type, args->operation,
+					&progress, NULL);
+	if (status !=3D 0)
+	args->status =3D status;
+}
+
+static struct ia64_pal_retval pal_cache_flush(struct kvm_vcpu *vcpu)
+{
+	u64 gr28, gr29, gr30, gr31;
+	struct ia64_pal_retval result =3D {0, 0, 0, 0};
+	struct cache_flush_args args =3D {0, 0, 0, 0};
+	long psr;
+
+	gr28 =3D gr29 =3D gr30 =3D gr31 =3D 0;
+	kvm_get_pal_call_data(vcpu, &gr28, &gr29, &gr30, &gr31);
+
+	if (gr31 !=3D 0)
+		printk(KERN_ERR"vcpu:%p called cache_flush error!\n",
vcpu);
+
+	/* Always call Host Pal in int=3D1 */
+	gr30 &=3D ~PAL_CACHE_FLUSH_CHK_INTRS;
+	args.cache_type =3D gr29;
+	args.operation =3D gr30;
+	smp_call_function(remote_pal_cache_flush,
+				(void *)&args, 1, 1);
+	if (args.status !=3D 0)
+		printk(KERN_ERR"pal_cache_flush error!,"
+				"status:0x%lx\n", args.status);
+	/*
+	 * Call Host PAL cache flush
+	 * Clear psr.ic when call PAL_CACHE_FLUSH
+	 */
+	local_irq_save(psr);
+	result.status =3D ia64_pal_cache_flush(gr29, gr30, &result.v1,
+						&result.v0);
+	local_irq_restore(psr);
+	if (result.status !=3D 0)
+		printk(KERN_ERR"vcpu:%p crashed due to cache_flush
err:%ld"
+				"in1:%lx,in2:%lx\n",
+				vcpu, result.status, gr29, gr30);
+
+#if 0
+	if (gr29 =3D=3D PAL_CACHE_TYPE_COHERENT) {
+		cpus_setall(vcpu->arch.cache_coherent_map);
+		cpu_clear(vcpu->cpu, vcpu->arch.cache_coherent_map);
+		cpus_setall(cpu_cache_coherent_map);
+		cpu_clear(vcpu->cpu, cpu_cache_coherent_map);
+	}
+#endif
+	return result;
+}
+
+struct ia64_pal_retval pal_cache_summary(struct kvm_vcpu *vcpu)
+{
+
+	struct ia64_pal_retval result;
+
+	PAL_CALL(result, PAL_CACHE_SUMMARY, 0, 0, 0);
+	return result;
+}
+
+static struct ia64_pal_retval pal_freq_base(struct kvm_vcpu *vcpu)
+{
+
+	struct ia64_pal_retval result;
+
+	PAL_CALL(result, PAL_FREQ_BASE, 0, 0, 0);
+
+	/*
+	 * PAL_FREQ_BASE may not be implemented in some platforms,
+	 * call SAL instead.
+	 */
+	if (result.v0 =3D=3D 0) {
+		result.status =3D
ia64_sal_freq_base(SAL_FREQ_BASE_PLATFORM,
+							&result.v0,
+							&result.v1);
+		result.v2 =3D 0;
+	}
+
+	return result;
+}
+
+static struct ia64_pal_retval pal_freq_ratios(struct kvm_vcpu *vcpu)
+{
+
+	struct ia64_pal_retval result;
+
+	PAL_CALL(result, PAL_FREQ_RATIOS, 0, 0, 0);
+	return result;
+}
+
+static struct ia64_pal_retval pal_logical_to_physica(struct kvm_vcpu
*vcpu)
+{
+	struct ia64_pal_retval result;
+
+	INIT_PAL_STATUS_UNIMPLEMENTED(result);
+	return result;
+}
+
+static struct ia64_pal_retval pal_platform_addr(struct kvm_vcpu *vcpu)
+{
+
+	struct ia64_pal_retval result;
+
+	INIT_PAL_STATUS_SUCCESS(result);
+	return result;
+}
+
+static struct ia64_pal_retval pal_proc_get_features(struct kvm_vcpu
*vcpu)
+{
+
+	struct ia64_pal_retval result =3D {0, 0, 0, 0};
+	long in0, in1, in2, in3;
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	result.status =3D ia64_pal_proc_get_features(&result.v0,
&result.v1,
+			&result.v2, in2);
+
+	return result;
+}
+
+static struct ia64_pal_retval pal_cache_info(struct kvm_vcpu *vcpu)
+{
+
+	pal_cache_config_info_t ci;
+	long status;
+	unsigned long in0, in1, in2, in3, r9, r10;
+
+	kvm_get_pal_call_data(vcpu, &in0, &in1, &in2, &in3);
+	status =3D ia64_pal_cache_config_info(in1, in2, &ci);
+	r9 =3D ci.pcci_info_1.pcci1_data;
+	r10 =3D ci.pcci_info_2.pcci2_data;
+	return ((struct ia64_pal_retval){status, r9, r10, 0});
+}
+
+#define GUEST_IMPL_VA_MSB	59
+#define GUEST_RID_BITS		18
+
+static struct ia64_pal_retval pal_vm_summary(struct kvm_vcpu *vcpu)
+{
+
+	pal_vm_info_1_u_t vminfo1;
+	pal_vm_info_2_u_t vminfo2;
+	struct ia64_pal_retval result;
+
+	PAL_CALL(result, PAL_VM_SUMMARY, 0, 0, 0);
+	if (!result.status) {
+		vminfo1.pvi1_val =3D result.v0;
+		vminfo1.pal_vm_info_1_s.max_itr_entry =3D 8;
+		vminfo1.pal_vm_info_1_s.max_dtr_entry =3D 8;
+		result.v0 =3D vminfo1.pvi1_val;
+		vminfo2.pal_vm_info_2_s.impl_va_msb =3D GUEST_IMPL_VA_MSB;
+		vminfo2.pal_vm_info_2_s.rid_size =3D GUEST_RID_BITS;
+		result.v1 =3D vminfo2.pvi2_val;
+	}
+
+	return result;
+}
+
+static struct ia64_pal_retval pal_vm_info(struct kvm_vcpu *vcpu)
+{
+	struct ia64_pal_retval result;
+
+	INIT_PAL_STATUS_UNIMPLEMENTED(result);
+
+	return result;
+}
+
+static  u64 kvm_get_pal_call_index(struct kvm_vcpu *vcpu)
+{
+	u64 index =3D 0;
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+	if (p && (p->exit_reason =3D=3D EXIT_REASON_PAL_CALL)) {
+		index =3D p->u.pal_data.gr28;
+	}
+	return index;
+}
+
+int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_run *run)
+{
+
+	u64 gr28;
+	struct ia64_pal_retval result;
+	int ret =3D 1;
+
+	gr28 =3D kvm_get_pal_call_index(vcpu);
+	/*printk("pal_call index:%lx\n",gr28);*/
+	switch (gr28) {
+	case PAL_CACHE_FLUSH:
+		result =3D pal_cache_flush(vcpu);
+		break;
+	case PAL_CACHE_SUMMARY:
+		result =3D pal_cache_summary(vcpu);
+		break;
+	case PAL_HALT_LIGHT:
+	{
+		vcpu->arch.timer_pending =3D 1;
+		INIT_PAL_STATUS_SUCCESS(result);
+		if (kvm_highest_pending_irq(vcpu) =3D=3D -1) {
+			ret =3D kvm_emulate_halt(vcpu);
+		}
+	}
+		break;
+
+	case PAL_FREQ_RATIOS:
+		result =3D pal_freq_ratios(vcpu);
+		break;
+
+	case PAL_FREQ_BASE:
+		result =3D pal_freq_base(vcpu);
+		break;
+
+	case PAL_LOGICAL_TO_PHYSICAL :
+		result =3D pal_logical_to_physica(vcpu);
+		break;
+
+	case PAL_VM_SUMMARY :
+		result =3D pal_vm_summary(vcpu);
+		break;
+
+	case PAL_VM_INFO :
+		result =3D pal_vm_info(vcpu);
+		break;
+	case PAL_PLATFORM_ADDR :
+		result =3D pal_platform_addr(vcpu);
+		break;
+	case PAL_CACHE_INFO:
+		result =3D pal_cache_info(vcpu);
+		break;
+	case PAL_PTCE_INFO:
+		INIT_PAL_STATUS_SUCCESS(result);
+		result.v1 =3D (1L << 32) | 1L;
+		break;
+	case PAL_VM_PAGE_SIZE:
+		result.status =3D ia64_pal_vm_page_size(&result.v0,
+							&result.v1);
+		break;
+	case PAL_RSE_INFO:
+		result.status =3D ia64_pal_rse_info(&result.v0,
+					(pal_hints_u_t *)&result.v1);
+		break;
+	case PAL_PROC_GET_FEATURES:
+		result =3D pal_proc_get_features(vcpu);
+		break;
+	case PAL_DEBUG_INFO:
+		result.status =3D ia64_pal_debug_info(&result.v0,
+							&result.v1);
+		break;
+	case PAL_VERSION:
+		result.status =3D ia64_pal_version(
+				(pal_version_u_t *)&result.v0,
+				(pal_version_u_t *)&result.v1);
+
+		break;
+	case PAL_FIXED_ADDR:
+		result.status =3D PAL_STATUS_SUCCESS;
+		result.v0 =3D vcpu->vcpu_id;
+		break;
+	default:
+		INIT_PAL_STATUS_UNIMPLEMENTED(result);
+		printk(KERN_WARNING"kvm: Unsupported pal call,"
+					" index:0x%lx\n", gr28);
+	}
+	set_pal_result(vcpu, result);
+	return ret;
+}
+
+static struct sal_ret_values sal_emulator(struct kvm *kvm,
+				long index, unsigned long in1,
+				unsigned long in2, unsigned long in3,
+				unsigned long in4, unsigned long in5,
+				unsigned long in6, unsigned long in7)
+{
+	unsigned long r9  =3D 0;
+	unsigned long r10 =3D 0;
+	long r11 =3D 0;
+	long status;
+
+	status =3D 0;
+	switch (index) {
+	case SAL_FREQ_BASE:
+		status =3D ia64_sal_freq_base(in1, &r9, &r10);
+		break;
+	case SAL_PCI_CONFIG_READ:
+		printk(KERN_WARNING"kvm: Not allowed to call here!"
+			" SAL_PCI_CONFIG_READ\n");
+		break;
+	case SAL_PCI_CONFIG_WRITE:
+		printk(KERN_WARNING"kvm: Not allowed to call here!"
+			" SAL_PCI_CONFIG_WRITE\n");
+		break;
+	case SAL_SET_VECTORS:
+		if (in1 =3D=3D SAL_VECTOR_OS_BOOT_RENDEZ) {
+			if (in4 !=3D 0 || in5 !=3D 0 || in6 !=3D 0 || in7 !=3D
0) {
+				status =3D -2;
+			} else {
+				kvm->arch.rdv_sal_data.boot_ip =3D in2;
+				kvm->arch.rdv_sal_data.boot_gp =3D in3;
+			}
+			printk("Rendvous called! iip:%lx\n\n", in2);
+		} else
+			printk(KERN_WARNING"kvm: CALLED SAL_SET_VECTORS
%lu."
+							"ignored...\n",
in1);
+		break;
+	case SAL_GET_STATE_INFO:
+		/* No more info.  */
+		status =3D -5;
+		r9 =3D 0;
+		break;
+	case SAL_GET_STATE_INFO_SIZE:
+		/* Return a dummy size.  */
+		status =3D 0;
+		r9 =3D 128;
+		break;
+	case SAL_CLEAR_STATE_INFO:
+		/* Noop.  */
+		break;
+	case SAL_MC_RENDEZ:
+		printk(KERN_WARNING
+			"kvm: called SAL_MC_RENDEZ. ignored...\n");
+		break;
+	case SAL_MC_SET_PARAMS:
+		printk(KERN_WARNING
+			"kvm: called  SAL_MC_SET_PARAMS.ignored!\n");
+		break;
+	case SAL_CACHE_FLUSH:
+		if (1) {
+			/*Flush using SAL.
+			This method is faster but has a side
+			effect on other vcpu running on
+			this cpu.  */
+			status =3D ia64_sal_cache_flush(in1);
+		} else {
+			/*Maybe need to implement the method
+			without side effect!*/
+			status =3D 0;
+		}
+		break;
+	case SAL_CACHE_INIT:
+		printk(KERN_WARNING
+			"kvm: called SAL_CACHE_INIT.  ignored...\n");
+		break;
+	case SAL_UPDATE_PAL:
+		printk(KERN_WARNING
+			"kvm: CALLED SAL_UPDATE_PAL.  ignored...\n");
+		break;
+	default:
+		printk(KERN_WARNING"kvm: called SAL_CALL with unknown
index."
+						" index:%ld\n", index);
+		status =3D -1;
+		break;
+	}
+	return ((struct sal_ret_values) {status, r9, r10, r11});
+}
+
+static void kvm_get_sal_call_data(struct kvm_vcpu *vcpu, u64 *in0, u64
*in1,
+		u64 *in2, u64 *in3, u64 *in4, u64 *in5, u64 *in6, u64
*in7){
+
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+
+	if (p) {
+		if (p->exit_reason =3D=3D EXIT_REASON_SAL_CALL) {
+			*in0 =3D p->u.sal_data.in0;
+			*in1 =3D p->u.sal_data.in1;
+			*in2 =3D p->u.sal_data.in2;
+			*in3 =3D p->u.sal_data.in3;
+			*in4 =3D p->u.sal_data.in4;
+			*in5 =3D p->u.sal_data.in5;
+			*in6 =3D p->u.sal_data.in6;
+			*in7 =3D p->u.sal_data.in7;
+			return ;
+		}
+	}
+	*in0 =3D 0;
+}
+
+void kvm_sal_emul(struct kvm_vcpu *vcpu)
+{
+
+	struct sal_ret_values result;
+	u64 index, in1, in2, in3, in4, in5, in6, in7;
+
+	kvm_get_sal_call_data(vcpu, &index, &in1, &in2,
+			&in3, &in4, &in5, &in6, &in7);
+	result =3D sal_emulator(vcpu->kvm, index, in1, in2, in3,
+					in4, in5, in6, in7);
+	set_sal_result(vcpu, result);
+}
--=20
1.5.2

------_=_NextPart_001_01C890BA.3E06072B
Content-Type: application/octet-stream;
	name="0015-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0015-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch
Content-Disposition: attachment;
	filename="0015-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch"

RnJvbSBiYTA2NGZjNzljNWQ4NTc3NTQzYWU2ZTRhMjAxZjYyMmYwYzRiNzc3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0MjoxOCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQga3ZtIHNhbC9wYWwgdmlydHVsaXphdGlvbiBzdXBwb3J0LgoKU29tZSBz
YWwvcGFsIGNhbGxzIHdvdWxkIGJlIHRyYXBlZCB0byBrdm0gZm9yIHZpcnR1bGl6YXRpb24KZnJv
bSBndWVzdCBmaXJtd2FyZS4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS9rdm1fZncuYyB8ICA1MDAgKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDUwMCBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0va3ZtX2Z3LmMKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL2t2bV9m
dy5jIGIvYXJjaC9pYTY0L2t2bS9rdm1fZncuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAw
MDAwMDAwLi4wNzdkNmU3Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9rdm1fZncu
YwpAQCAtMCwwICsxLDUwMCBAQAorLyoKKyAqIFBBTC9TQUwgY2FsbCBkZWxlZ2F0aW9uCisgKgor
ICogQ29weXJpZ2h0IChjKSAyMDA0IExpIFN1c2llIDxzdXNpZS5saUBpbnRlbC5jb20+CisgKiBD
b3B5cmlnaHQgKGMpIDIwMDUgWXUgS2UgPGtlLnl1QGludGVsLmNvbT4KKyAqIENvcHlyaWdodCAo
YykgMjAwNyBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAqCisgKiBU
aGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5k
L29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBH
TlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5
IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRp
c3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICog
QU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hB
TlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0
aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgor
ICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRv
IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICogUGxhY2Ug
LSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKi8KKworI2luY2x1ZGUg
PGxpbnV4L2t2bV9ob3N0Lmg+CisjaW5jbHVkZSA8bGludXgvc21wLmg+CisKKyNpbmNsdWRlICJ2
dGkuaCIKKyNpbmNsdWRlICJtaXNjLmgiCisKKyNpbmNsdWRlIDxhc20vcGFsLmg+CisjaW5jbHVk
ZSA8YXNtL3NhbC5oPgorI2luY2x1ZGUgPGFzbS90bGIuaD4KKworLyoKKyAqIEhhbmR5IG1hY3Jv
cyB0byBtYWtlIHN1cmUgdGhhdCB0aGUgUEFMIHJldHVybiB2YWx1ZXMgc3RhcnQgb3V0CisgKiBh
cyBzb21ldGhpbmcgbWVhbmluZ2Z1bC4KKyAqLworI2RlZmluZSBJTklUX1BBTF9TVEFUVVNfVU5J
TVBMRU1FTlRFRCh4KQkJXAorCXsJCQkJCQlcCisJCXguc3RhdHVzID0gUEFMX1NUQVRVU19VTklN
UExFTUVOVEVEOwlcCisJCXgudjAgPSAwOwkJCQlcCisJCXgudjEgPSAwOwkJCQlcCisJCXgudjIg
PSAwOwkJCQlcCisJfQorCisjZGVmaW5lIElOSVRfUEFMX1NUQVRVU19TVUNDRVNTKHgpCQkJXAor
CXsJCQkJCQlcCisJCXguc3RhdHVzID0gUEFMX1NUQVRVU19TVUNDRVNTOwkJXAorCQl4LnYwID0g
MDsJCQkJXAorCQl4LnYxID0gMDsJCQkJXAorCQl4LnYyID0gMDsJCQkJXAorICAgIH0KKworc3Rh
dGljIHZvaWQga3ZtX2dldF9wYWxfY2FsbF9kYXRhKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwKKwkJ
dTY0ICpncjI4LCB1NjQgKmdyMjksIHU2NCAqZ3IzMCwgdTY0ICpncjMxKSB7CisJc3RydWN0IGV4
aXRfY3RsX2RhdGEgKnA7CisKKwlpZiAodmNwdSkgeworCQlwID0gJnZjcHUtPmFyY2guZXhpdF9k
YXRhOworCQlpZiAocC0+ZXhpdF9yZWFzb24gPT0gRVhJVF9SRUFTT05fUEFMX0NBTEwpIHsKKwkJ
CSpncjI4ID0gcC0+dS5wYWxfZGF0YS5ncjI4OworCQkJKmdyMjkgPSBwLT51LnBhbF9kYXRhLmdy
Mjk7CisJCQkqZ3IzMCA9IHAtPnUucGFsX2RhdGEuZ3IzMDsKKwkJCSpncjMxID0gcC0+dS5wYWxf
ZGF0YS5ncjMxOworCQkJcmV0dXJuIDsKKwkJfQorCX0KKwlwcmludGsoS0VSTl9ERUJVRyJFcnJv
ciBvY2N1cnMgaW4ga3ZtX2dldF9wYWxfY2FsbF9kYXRhISFcbiIpOworfQorCitzdGF0aWMgdm9p
ZCBzZXRfcGFsX3Jlc3VsdChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsCisJCXN0cnVjdCBpYTY0X3Bh
bF9yZXR2YWwgcmVzdWx0KSB7CisKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcDsKKworCXAgPSBr
dm1fZ2V0X2V4aXRfZGF0YSh2Y3B1KTsKKwlpZiAocCAmJiBwLT5leGl0X3JlYXNvbiA9PSBFWElU
X1JFQVNPTl9QQUxfQ0FMTCkgeworCQlwLT51LnBhbF9kYXRhLnJldCA9IHJlc3VsdDsKKwkJcmV0
dXJuIDsKKwl9CisJSU5JVF9QQUxfU1RBVFVTX1VOSU1QTEVNRU5URUQocC0+dS5wYWxfZGF0YS5y
ZXQpOworfQorCitzdGF0aWMgdm9pZCBzZXRfc2FsX3Jlc3VsdChzdHJ1Y3Qga3ZtX3ZjcHUgKnZj
cHUsCisJCXN0cnVjdCBzYWxfcmV0X3ZhbHVlcyByZXN1bHQpIHsKKwlzdHJ1Y3QgZXhpdF9jdGxf
ZGF0YSAqcDsKKworCXAgPSBrdm1fZ2V0X2V4aXRfZGF0YSh2Y3B1KTsKKwlpZiAocCAmJiBwLT5l
eGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9TQUxfQ0FMTCkgeworCQlwLT51LnNhbF9kYXRhLnJl
dCA9IHJlc3VsdDsKKwkJcmV0dXJuIDsKKwl9CisJcHJpbnRrKEtFUk5fV0FSTklORyJFcnJvciBv
Y2N1cnMhISFcbiIpOworfQorCitzdHJ1Y3QgY2FjaGVfZmx1c2hfYXJncyB7CisJdTY0IGNhY2hl
X3R5cGU7CisJdTY0IG9wZXJhdGlvbjsKKwl1NjQgcHJvZ3Jlc3M7CisJbG9uZyBzdGF0dXM7Cit9
OworCitjcHVtYXNrX3QgY3B1X2NhY2hlX2NvaGVyZW50X21hcDsKKworc3RhdGljIHZvaWQgcmVt
b3RlX3BhbF9jYWNoZV9mbHVzaCh2b2lkICpkYXRhKQoreworCXN0cnVjdCBjYWNoZV9mbHVzaF9h
cmdzICphcmdzID0gZGF0YTsKKwlsb25nIHN0YXR1czsKKwl1NjQgcHJvZ3Jlc3MgPSBhcmdzLT5w
cm9ncmVzczsKKworCXN0YXR1cyA9IGlhNjRfcGFsX2NhY2hlX2ZsdXNoKGFyZ3MtPmNhY2hlX3R5
cGUsIGFyZ3MtPm9wZXJhdGlvbiwKKwkJCQkJJnByb2dyZXNzLCBOVUxMKTsKKwlpZiAoc3RhdHVz
ICE9IDApCisJYXJncy0+c3RhdHVzID0gc3RhdHVzOworfQorCitzdGF0aWMgc3RydWN0IGlhNjRf
cGFsX3JldHZhbCBwYWxfY2FjaGVfZmx1c2goc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCXU2
NCBncjI4LCBncjI5LCBncjMwLCBncjMxOworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0
ID0gezAsIDAsIDAsIDB9OworCXN0cnVjdCBjYWNoZV9mbHVzaF9hcmdzIGFyZ3MgPSB7MCwgMCwg
MCwgMH07CisJbG9uZyBwc3I7CisKKwlncjI4ID0gZ3IyOSA9IGdyMzAgPSBncjMxID0gMDsKKwlr
dm1fZ2V0X3BhbF9jYWxsX2RhdGEodmNwdSwgJmdyMjgsICZncjI5LCAmZ3IzMCwgJmdyMzEpOwor
CisJaWYgKGdyMzEgIT0gMCkKKwkJcHJpbnRrKEtFUk5fRVJSInZjcHU6JXAgY2FsbGVkIGNhY2hl
X2ZsdXNoIGVycm9yIVxuIiwgdmNwdSk7CisKKwkvKiBBbHdheXMgY2FsbCBIb3N0IFBhbCBpbiBp
bnQ9MSAqLworCWdyMzAgJj0gflBBTF9DQUNIRV9GTFVTSF9DSEtfSU5UUlM7CisJYXJncy5jYWNo
ZV90eXBlID0gZ3IyOTsKKwlhcmdzLm9wZXJhdGlvbiA9IGdyMzA7CisJc21wX2NhbGxfZnVuY3Rp
b24ocmVtb3RlX3BhbF9jYWNoZV9mbHVzaCwKKwkJCQkodm9pZCAqKSZhcmdzLCAxLCAxKTsKKwlp
ZiAoYXJncy5zdGF0dXMgIT0gMCkKKwkJcHJpbnRrKEtFUk5fRVJSInBhbF9jYWNoZV9mbHVzaCBl
cnJvciEsIgorCQkJCSJzdGF0dXM6MHglbHhcbiIsIGFyZ3Muc3RhdHVzKTsKKwkvKgorCSAqIENh
bGwgSG9zdCBQQUwgY2FjaGUgZmx1c2gKKwkgKiBDbGVhciBwc3IuaWMgd2hlbiBjYWxsIFBBTF9D
QUNIRV9GTFVTSAorCSAqLworCWxvY2FsX2lycV9zYXZlKHBzcik7CisJcmVzdWx0LnN0YXR1cyA9
IGlhNjRfcGFsX2NhY2hlX2ZsdXNoKGdyMjksIGdyMzAsICZyZXN1bHQudjEsCisJCQkJCQkmcmVz
dWx0LnYwKTsKKwlsb2NhbF9pcnFfcmVzdG9yZShwc3IpOworCWlmIChyZXN1bHQuc3RhdHVzICE9
IDApCisJCXByaW50ayhLRVJOX0VSUiJ2Y3B1OiVwIGNyYXNoZWQgZHVlIHRvIGNhY2hlX2ZsdXNo
IGVycjolbGQiCisJCQkJImluMTolbHgsaW4yOiVseFxuIiwKKwkJCQl2Y3B1LCByZXN1bHQuc3Rh
dHVzLCBncjI5LCBncjMwKTsKKworI2lmIDAKKwlpZiAoZ3IyOSA9PSBQQUxfQ0FDSEVfVFlQRV9D
T0hFUkVOVCkgeworCQljcHVzX3NldGFsbCh2Y3B1LT5hcmNoLmNhY2hlX2NvaGVyZW50X21hcCk7
CisJCWNwdV9jbGVhcih2Y3B1LT5jcHUsIHZjcHUtPmFyY2guY2FjaGVfY29oZXJlbnRfbWFwKTsK
KwkJY3B1c19zZXRhbGwoY3B1X2NhY2hlX2NvaGVyZW50X21hcCk7CisJCWNwdV9jbGVhcih2Y3B1
LT5jcHUsIGNwdV9jYWNoZV9jb2hlcmVudF9tYXApOworCX0KKyNlbmRpZgorCXJldHVybiByZXN1
bHQ7Cit9CisKK3N0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX2NhY2hlX3N1bW1hcnkoc3RydWN0
IGt2bV92Y3B1ICp2Y3B1KQoreworCisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisK
KwlQQUxfQ0FMTChyZXN1bHQsIFBBTF9DQUNIRV9TVU1NQVJZLCAwLCAwLCAwKTsKKwlyZXR1cm4g
cmVzdWx0OworfQorCitzdGF0aWMgc3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfZnJlcV9iYXNl
KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVz
dWx0OworCisJUEFMX0NBTEwocmVzdWx0LCBQQUxfRlJFUV9CQVNFLCAwLCAwLCAwKTsKKworCS8q
CisJICogUEFMX0ZSRVFfQkFTRSBtYXkgbm90IGJlIGltcGxlbWVudGVkIGluIHNvbWUgcGxhdGZv
cm1zLAorCSAqIGNhbGwgU0FMIGluc3RlYWQuCisJICovCisJaWYgKHJlc3VsdC52MCA9PSAwKSB7
CisJCXJlc3VsdC5zdGF0dXMgPSBpYTY0X3NhbF9mcmVxX2Jhc2UoU0FMX0ZSRVFfQkFTRV9QTEFU
Rk9STSwKKwkJCQkJCQkmcmVzdWx0LnYwLAorCQkJCQkJCSZyZXN1bHQudjEpOworCQlyZXN1bHQu
djIgPSAwOworCX0KKworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaWE2NF9w
YWxfcmV0dmFsIHBhbF9mcmVxX3JhdGlvcyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisKKwlz
dHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKworCVBBTF9DQUxMKHJlc3VsdCwgUEFMX0ZS
RVFfUkFUSU9TLCAwLCAwLCAwKTsKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMgc3RydWN0
IGlhNjRfcGFsX3JldHZhbCBwYWxfbG9naWNhbF90b19waHlzaWNhKHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSkKK3sKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKworCUlOSVRfUEFMX1NU
QVRVU19VTklNUExFTUVOVEVEKHJlc3VsdCk7CisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGlj
IHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX3BsYXRmb3JtX2FkZHIoc3RydWN0IGt2bV92Y3B1
ICp2Y3B1KQoreworCisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisKKwlJTklUX1BB
TF9TVEFUVVNfU1VDQ0VTUyhyZXN1bHQpOworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyBz
dHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9wcm9jX2dldF9mZWF0dXJlcyhzdHJ1Y3Qga3ZtX3Zj
cHUgKnZjcHUpCit7CisKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdCA9IHswLCAwLCAw
LCAwfTsKKwlsb25nIGluMCwgaW4xLCBpbjIsIGluMzsKKworCWt2bV9nZXRfcGFsX2NhbGxfZGF0
YSh2Y3B1LCAmaW4wLCAmaW4xLCAmaW4yLCAmaW4zKTsKKwlyZXN1bHQuc3RhdHVzID0gaWE2NF9w
YWxfcHJvY19nZXRfZmVhdHVyZXMoJnJlc3VsdC52MCwgJnJlc3VsdC52MSwKKwkJCSZyZXN1bHQu
djIsIGluMik7CisKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMgc3RydWN0IGlhNjRfcGFs
X3JldHZhbCBwYWxfY2FjaGVfaW5mbyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisKKwlwYWxf
Y2FjaGVfY29uZmlnX2luZm9fdCBjaTsKKwlsb25nIHN0YXR1czsKKwl1bnNpZ25lZCBsb25nIGlu
MCwgaW4xLCBpbjIsIGluMywgcjksIHIxMDsKKworCWt2bV9nZXRfcGFsX2NhbGxfZGF0YSh2Y3B1
LCAmaW4wLCAmaW4xLCAmaW4yLCAmaW4zKTsKKwlzdGF0dXMgPSBpYTY0X3BhbF9jYWNoZV9jb25m
aWdfaW5mbyhpbjEsIGluMiwgJmNpKTsKKwlyOSA9IGNpLnBjY2lfaW5mb18xLnBjY2kxX2RhdGE7
CisJcjEwID0gY2kucGNjaV9pbmZvXzIucGNjaTJfZGF0YTsKKwlyZXR1cm4gKChzdHJ1Y3QgaWE2
NF9wYWxfcmV0dmFsKXtzdGF0dXMsIHI5LCByMTAsIDB9KTsKK30KKworI2RlZmluZSBHVUVTVF9J
TVBMX1ZBX01TQgk1OQorI2RlZmluZSBHVUVTVF9SSURfQklUUwkJMTgKKworc3RhdGljIHN0cnVj
dCBpYTY0X3BhbF9yZXR2YWwgcGFsX3ZtX3N1bW1hcnkoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQor
eworCisJcGFsX3ZtX2luZm9fMV91X3Qgdm1pbmZvMTsKKwlwYWxfdm1faW5mb18yX3VfdCB2bWlu
Zm8yOworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCisJUEFMX0NBTEwocmVzdWx0
LCBQQUxfVk1fU1VNTUFSWSwgMCwgMCwgMCk7CisJaWYgKCFyZXN1bHQuc3RhdHVzKSB7CisJCXZt
aW5mbzEucHZpMV92YWwgPSByZXN1bHQudjA7CisJCXZtaW5mbzEucGFsX3ZtX2luZm9fMV9zLm1h
eF9pdHJfZW50cnkgPSA4OworCQl2bWluZm8xLnBhbF92bV9pbmZvXzFfcy5tYXhfZHRyX2VudHJ5
ID0gODsKKwkJcmVzdWx0LnYwID0gdm1pbmZvMS5wdmkxX3ZhbDsKKwkJdm1pbmZvMi5wYWxfdm1f
aW5mb18yX3MuaW1wbF92YV9tc2IgPSBHVUVTVF9JTVBMX1ZBX01TQjsKKwkJdm1pbmZvMi5wYWxf
dm1faW5mb18yX3MucmlkX3NpemUgPSBHVUVTVF9SSURfQklUUzsKKwkJcmVzdWx0LnYxID0gdm1p
bmZvMi5wdmkyX3ZhbDsKKwl9CisKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMgc3RydWN0
IGlhNjRfcGFsX3JldHZhbCBwYWxfdm1faW5mbyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJ
c3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisKKwlJTklUX1BBTF9TVEFUVVNfVU5JTVBM
RU1FTlRFRChyZXN1bHQpOworCisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljICB1NjQga3Zt
X2dldF9wYWxfY2FsbF9pbmRleChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJdTY0IGluZGV4
ID0gMDsKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcDsKKworCXAgPSBrdm1fZ2V0X2V4aXRfZGF0
YSh2Y3B1KTsKKwlpZiAocCAmJiAocC0+ZXhpdF9yZWFzb24gPT0gRVhJVF9SRUFTT05fUEFMX0NB
TEwpKSB7CisJCWluZGV4ID0gcC0+dS5wYWxfZGF0YS5ncjI4OworCX0KKwlyZXR1cm4gaW5kZXg7
Cit9CisKK2ludCBrdm1fcGFsX2VtdWwoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3Zt
X3J1biAqcnVuKQoreworCisJdTY0IGdyMjg7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1
bHQ7CisJaW50IHJldCA9IDE7CisKKwlncjI4ID0ga3ZtX2dldF9wYWxfY2FsbF9pbmRleCh2Y3B1
KTsKKwkvKnByaW50aygicGFsX2NhbGwgaW5kZXg6JWx4XG4iLGdyMjgpOyovCisJc3dpdGNoIChn
cjI4KSB7CisJY2FzZSBQQUxfQ0FDSEVfRkxVU0g6CisJCXJlc3VsdCA9IHBhbF9jYWNoZV9mbHVz
aCh2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfQ0FDSEVfU1VNTUFSWToKKwkJcmVzdWx0ID0g
cGFsX2NhY2hlX3N1bW1hcnkodmNwdSk7CisJCWJyZWFrOworCWNhc2UgUEFMX0hBTFRfTElHSFQ6
CisJeworCQl2Y3B1LT5hcmNoLnRpbWVyX3BlbmRpbmcgPSAxOworCQlJTklUX1BBTF9TVEFUVVNf
U1VDQ0VTUyhyZXN1bHQpOworCQlpZiAoa3ZtX2hpZ2hlc3RfcGVuZGluZ19pcnEodmNwdSkgPT0g
LTEpIHsKKwkJCXJldCA9IGt2bV9lbXVsYXRlX2hhbHQodmNwdSk7CisJCX0KKwl9CisJCWJyZWFr
OworCisJY2FzZSBQQUxfRlJFUV9SQVRJT1M6CisJCXJlc3VsdCA9IHBhbF9mcmVxX3JhdGlvcyh2
Y3B1KTsKKwkJYnJlYWs7CisKKwljYXNlIFBBTF9GUkVRX0JBU0U6CisJCXJlc3VsdCA9IHBhbF9m
cmVxX2Jhc2UodmNwdSk7CisJCWJyZWFrOworCisJY2FzZSBQQUxfTE9HSUNBTF9UT19QSFlTSUNB
TCA6CisJCXJlc3VsdCA9IHBhbF9sb2dpY2FsX3RvX3BoeXNpY2EodmNwdSk7CisJCWJyZWFrOwor
CisJY2FzZSBQQUxfVk1fU1VNTUFSWSA6CisJCXJlc3VsdCA9IHBhbF92bV9zdW1tYXJ5KHZjcHUp
OworCQlicmVhazsKKworCWNhc2UgUEFMX1ZNX0lORk8gOgorCQlyZXN1bHQgPSBwYWxfdm1faW5m
byh2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfUExBVEZPUk1fQUREUiA6CisJCXJlc3VsdCA9
IHBhbF9wbGF0Zm9ybV9hZGRyKHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9DQUNIRV9JTkZP
OgorCQlyZXN1bHQgPSBwYWxfY2FjaGVfaW5mbyh2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxf
UFRDRV9JTkZPOgorCQlJTklUX1BBTF9TVEFUVVNfU1VDQ0VTUyhyZXN1bHQpOworCQlyZXN1bHQu
djEgPSAoMUwgPDwgMzIpIHwgMUw7CisJCWJyZWFrOworCWNhc2UgUEFMX1ZNX1BBR0VfU0laRToK
KwkJcmVzdWx0LnN0YXR1cyA9IGlhNjRfcGFsX3ZtX3BhZ2Vfc2l6ZSgmcmVzdWx0LnYwLAorCQkJ
CQkJCSZyZXN1bHQudjEpOworCQlicmVhazsKKwljYXNlIFBBTF9SU0VfSU5GTzoKKwkJcmVzdWx0
LnN0YXR1cyA9IGlhNjRfcGFsX3JzZV9pbmZvKCZyZXN1bHQudjAsCisJCQkJCShwYWxfaGludHNf
dV90ICopJnJlc3VsdC52MSk7CisJCWJyZWFrOworCWNhc2UgUEFMX1BST0NfR0VUX0ZFQVRVUkVT
OgorCQlyZXN1bHQgPSBwYWxfcHJvY19nZXRfZmVhdHVyZXModmNwdSk7CisJCWJyZWFrOworCWNh
c2UgUEFMX0RFQlVHX0lORk86CisJCXJlc3VsdC5zdGF0dXMgPSBpYTY0X3BhbF9kZWJ1Z19pbmZv
KCZyZXN1bHQudjAsCisJCQkJCQkJJnJlc3VsdC52MSk7CisJCWJyZWFrOworCWNhc2UgUEFMX1ZF
UlNJT046CisJCXJlc3VsdC5zdGF0dXMgPSBpYTY0X3BhbF92ZXJzaW9uKAorCQkJCShwYWxfdmVy
c2lvbl91X3QgKikmcmVzdWx0LnYwLAorCQkJCShwYWxfdmVyc2lvbl91X3QgKikmcmVzdWx0LnYx
KTsKKworCQlicmVhazsKKwljYXNlIFBBTF9GSVhFRF9BRERSOgorCQlyZXN1bHQuc3RhdHVzID0g
UEFMX1NUQVRVU19TVUNDRVNTOworCQlyZXN1bHQudjAgPSB2Y3B1LT52Y3B1X2lkOworCQlicmVh
azsKKwlkZWZhdWx0OgorCQlJTklUX1BBTF9TVEFUVVNfVU5JTVBMRU1FTlRFRChyZXN1bHQpOwor
CQlwcmludGsoS0VSTl9XQVJOSU5HImt2bTogVW5zdXBwb3J0ZWQgcGFsIGNhbGwsIgorCQkJCQki
IGluZGV4OjB4JWx4XG4iLCBncjI4KTsKKwl9CisJc2V0X3BhbF9yZXN1bHQodmNwdSwgcmVzdWx0
KTsKKwlyZXR1cm4gcmV0OworfQorCitzdGF0aWMgc3RydWN0IHNhbF9yZXRfdmFsdWVzIHNhbF9l
bXVsYXRvcihzdHJ1Y3Qga3ZtICprdm0sCisJCQkJbG9uZyBpbmRleCwgdW5zaWduZWQgbG9uZyBp
bjEsCisJCQkJdW5zaWduZWQgbG9uZyBpbjIsIHVuc2lnbmVkIGxvbmcgaW4zLAorCQkJCXVuc2ln
bmVkIGxvbmcgaW40LCB1bnNpZ25lZCBsb25nIGluNSwKKwkJCQl1bnNpZ25lZCBsb25nIGluNiwg
dW5zaWduZWQgbG9uZyBpbjcpCit7CisJdW5zaWduZWQgbG9uZyByOSAgPSAwOworCXVuc2lnbmVk
IGxvbmcgcjEwID0gMDsKKwlsb25nIHIxMSA9IDA7CisJbG9uZyBzdGF0dXM7CisKKwlzdGF0dXMg
PSAwOworCXN3aXRjaCAoaW5kZXgpIHsKKwljYXNlIFNBTF9GUkVRX0JBU0U6CisJCXN0YXR1cyA9
IGlhNjRfc2FsX2ZyZXFfYmFzZShpbjEsICZyOSwgJnIxMCk7CisJCWJyZWFrOworCWNhc2UgU0FM
X1BDSV9DT05GSUdfUkVBRDoKKwkJcHJpbnRrKEtFUk5fV0FSTklORyJrdm06IE5vdCBhbGxvd2Vk
IHRvIGNhbGwgaGVyZSEiCisJCQkiIFNBTF9QQ0lfQ09ORklHX1JFQURcbiIpOworCQlicmVhazsK
KwljYXNlIFNBTF9QQ0lfQ09ORklHX1dSSVRFOgorCQlwcmludGsoS0VSTl9XQVJOSU5HImt2bTog
Tm90IGFsbG93ZWQgdG8gY2FsbCBoZXJlISIKKwkJCSIgU0FMX1BDSV9DT05GSUdfV1JJVEVcbiIp
OworCQlicmVhazsKKwljYXNlIFNBTF9TRVRfVkVDVE9SUzoKKwkJaWYgKGluMSA9PSBTQUxfVkVD
VE9SX09TX0JPT1RfUkVOREVaKSB7CisJCQlpZiAoaW40ICE9IDAgfHwgaW41ICE9IDAgfHwgaW42
ICE9IDAgfHwgaW43ICE9IDApIHsKKwkJCQlzdGF0dXMgPSAtMjsKKwkJCX0gZWxzZSB7CisJCQkJ
a3ZtLT5hcmNoLnJkdl9zYWxfZGF0YS5ib290X2lwID0gaW4yOworCQkJCWt2bS0+YXJjaC5yZHZf
c2FsX2RhdGEuYm9vdF9ncCA9IGluMzsKKwkJCX0KKwkJCXByaW50aygiUmVuZHZvdXMgY2FsbGVk
ISBpaXA6JWx4XG5cbiIsIGluMik7CisJCX0gZWxzZQorCQkJcHJpbnRrKEtFUk5fV0FSTklORyJr
dm06IENBTExFRCBTQUxfU0VUX1ZFQ1RPUlMgJWx1LiIKKwkJCQkJCQkiaWdub3JlZC4uLlxuIiwg
aW4xKTsKKwkJYnJlYWs7CisJY2FzZSBTQUxfR0VUX1NUQVRFX0lORk86CisJCS8qIE5vIG1vcmUg
aW5mby4gICovCisJCXN0YXR1cyA9IC01OworCQlyOSA9IDA7CisJCWJyZWFrOworCWNhc2UgU0FM
X0dFVF9TVEFURV9JTkZPX1NJWkU6CisJCS8qIFJldHVybiBhIGR1bW15IHNpemUuICAqLworCQlz
dGF0dXMgPSAwOworCQlyOSA9IDEyODsKKwkJYnJlYWs7CisJY2FzZSBTQUxfQ0xFQVJfU1RBVEVf
SU5GTzoKKwkJLyogTm9vcC4gICovCisJCWJyZWFrOworCWNhc2UgU0FMX01DX1JFTkRFWjoKKwkJ
cHJpbnRrKEtFUk5fV0FSTklORworCQkJImt2bTogY2FsbGVkIFNBTF9NQ19SRU5ERVouIGlnbm9y
ZWQuLi5cbiIpOworCQlicmVhazsKKwljYXNlIFNBTF9NQ19TRVRfUEFSQU1TOgorCQlwcmludGso
S0VSTl9XQVJOSU5HCisJCQkia3ZtOiBjYWxsZWQgIFNBTF9NQ19TRVRfUEFSQU1TLmlnbm9yZWQh
XG4iKTsKKwkJYnJlYWs7CisJY2FzZSBTQUxfQ0FDSEVfRkxVU0g6CisJCWlmICgxKSB7CisJCQkv
KkZsdXNoIHVzaW5nIFNBTC4KKwkJCVRoaXMgbWV0aG9kIGlzIGZhc3RlciBidXQgaGFzIGEgc2lk
ZQorCQkJZWZmZWN0IG9uIG90aGVyIHZjcHUgcnVubmluZyBvbgorCQkJdGhpcyBjcHUuICAqLwor
CQkJc3RhdHVzID0gaWE2NF9zYWxfY2FjaGVfZmx1c2goaW4xKTsKKwkJfSBlbHNlIHsKKwkJCS8q
TWF5YmUgbmVlZCB0byBpbXBsZW1lbnQgdGhlIG1ldGhvZAorCQkJd2l0aG91dCBzaWRlIGVmZmVj
dCEqLworCQkJc3RhdHVzID0gMDsKKwkJfQorCQlicmVhazsKKwljYXNlIFNBTF9DQUNIRV9JTklU
OgorCQlwcmludGsoS0VSTl9XQVJOSU5HCisJCQkia3ZtOiBjYWxsZWQgU0FMX0NBQ0hFX0lOSVQu
ICBpZ25vcmVkLi4uXG4iKTsKKwkJYnJlYWs7CisJY2FzZSBTQUxfVVBEQVRFX1BBTDoKKwkJcHJp
bnRrKEtFUk5fV0FSTklORworCQkJImt2bTogQ0FMTEVEIFNBTF9VUERBVEVfUEFMLiAgaWdub3Jl
ZC4uLlxuIik7CisJCWJyZWFrOworCWRlZmF1bHQ6CisJCXByaW50ayhLRVJOX1dBUk5JTkcia3Zt
OiBjYWxsZWQgU0FMX0NBTEwgd2l0aCB1bmtub3duIGluZGV4LiIKKwkJCQkJCSIgaW5kZXg6JWxk
XG4iLCBpbmRleCk7CisJCXN0YXR1cyA9IC0xOworCQlicmVhazsKKwl9CisJcmV0dXJuICgoc3Ry
dWN0IHNhbF9yZXRfdmFsdWVzKSB7c3RhdHVzLCByOSwgcjEwLCByMTF9KTsKK30KKworc3RhdGlj
IHZvaWQga3ZtX2dldF9zYWxfY2FsbF9kYXRhKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0ICpp
bjAsIHU2NCAqaW4xLAorCQl1NjQgKmluMiwgdTY0ICppbjMsIHU2NCAqaW40LCB1NjQgKmluNSwg
dTY0ICppbjYsIHU2NCAqaW43KXsKKworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwOworCisJcCA9
IGt2bV9nZXRfZXhpdF9kYXRhKHZjcHUpOworCisJaWYgKHApIHsKKwkJaWYgKHAtPmV4aXRfcmVh
c29uID09IEVYSVRfUkVBU09OX1NBTF9DQUxMKSB7CisJCQkqaW4wID0gcC0+dS5zYWxfZGF0YS5p
bjA7CisJCQkqaW4xID0gcC0+dS5zYWxfZGF0YS5pbjE7CisJCQkqaW4yID0gcC0+dS5zYWxfZGF0
YS5pbjI7CisJCQkqaW4zID0gcC0+dS5zYWxfZGF0YS5pbjM7CisJCQkqaW40ID0gcC0+dS5zYWxf
ZGF0YS5pbjQ7CisJCQkqaW41ID0gcC0+dS5zYWxfZGF0YS5pbjU7CisJCQkqaW42ID0gcC0+dS5z
YWxfZGF0YS5pbjY7CisJCQkqaW43ID0gcC0+dS5zYWxfZGF0YS5pbjc7CisJCQlyZXR1cm4gOwor
CQl9CisJfQorCSppbjAgPSAwOworfQorCit2b2lkIGt2bV9zYWxfZW11bChzdHJ1Y3Qga3ZtX3Zj
cHUgKnZjcHUpCit7CisKKwlzdHJ1Y3Qgc2FsX3JldF92YWx1ZXMgcmVzdWx0OworCXU2NCBpbmRl
eCwgaW4xLCBpbjIsIGluMywgaW40LCBpbjUsIGluNiwgaW43OworCisJa3ZtX2dldF9zYWxfY2Fs
bF9kYXRhKHZjcHUsICZpbmRleCwgJmluMSwgJmluMiwKKwkJCSZpbjMsICZpbjQsICZpbjUsICZp
bjYsICZpbjcpOworCXJlc3VsdCA9IHNhbF9lbXVsYXRvcih2Y3B1LT5rdm0sIGluZGV4LCBpbjEs
IGluMiwgaW4zLAorCQkJCQlpbjQsIGluNSwgaW42LCBpbjcpOworCXNldF9zYWxfcmVzdWx0KHZj
cHUsIHJlc3VsdCk7Cit9Ci0tIAoxLjUuMgoK

------_=_NextPart_001_01C890BA.3E06072B--
