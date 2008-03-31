From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:31:27 +0000
Subject: [15/17][PATCH] kvm/ia64: Add kvm sal/pal virtulization support. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104825B@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.9CF3682F"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF1@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF1@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.9CF3682F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From e9f15f3838626eacface8a863394e6b8825182be Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:42:18 +0800
Subject: [PATCH] KVM:IA64 : Add kvm sal/pal virtulization support.

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

------_=_NextPart_001_01C89309.9CF3682F
Content-Type: application/octet-stream;
	name="0015-KVM-IA64-Add-kvm-sal-pal-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0015-KVM-IA64-Add-kvm-sal-pal-virtulization-support.patch
Content-Disposition: attachment;
	filename="0015-KVM-IA64-Add-kvm-sal-pal-virtulization-support.patch"

RnJvbSBlOWYxNWYzODM4NjI2ZWFjZmFjZThhODYzMzk0ZTZiODgyNTE4MmJlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0MjoxOCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogQWRkIGt2bSBzYWwvcGFsIHZpcnR1bGl6YXRpb24gc3VwcG9ydC4KClNvbWUg
c2FsL3BhbCBjYWxscyB3b3VsZCBiZSB0cmFwZWQgdG8ga3ZtIGZvciB2aXJ0dWxpemF0aW9uCmZy
b20gZ3Vlc3QgZmlybXdhcmUuClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8u
emhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0va3ZtX2Z3LmMgfCAgNTAwICsrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMSBmaWxlcyBjaGFu
Z2VkLCA1MDAgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0
NCBhcmNoL2lhNjQva3ZtL2t2bV9mdy5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9rdm1f
ZncuYyBiL2FyY2gvaWE2NC9rdm0va3ZtX2Z3LmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXgg
MDAwMDAwMC4uMDc3ZDZlNwotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2NC9rdm0va3ZtX2Z3
LmMKQEAgLTAsMCArMSw1MDAgQEAKKy8qCisgKiBQQUwvU0FMIGNhbGwgZGVsZWdhdGlvbgorICoK
KyAqIENvcHlyaWdodCAoYykgMjAwNCBMaSBTdXNpZSA8c3VzaWUubGlAaW50ZWwuY29tPgorICog
Q29weXJpZ2h0IChjKSAyMDA1IFl1IEtlIDxrZS55dUBpbnRlbC5jb20+CisgKiBDb3B5cmlnaHQg
KGMpIDIwMDcgWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisgKgorICog
VGhpcyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFu
ZC9vciBtb2RpZnkgaXQKKyAqIHVuZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUg
R05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBi
eSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBk
aXN0cmlidXRlZCBpbiB0aGUgaG9wZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAq
IEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNI
QU5UQUJJTElUWSBvcgorICogRklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoK
KyAqIFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1
YmxpYyBMaWNlbnNlIGFsb25nIHdpdGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0
byB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNl
IC0gU3VpdGUgMzMwLCBCb3N0b24sIE1BIDAyMTExLTEzMDcgVVNBLgorICovCisKKyNpbmNsdWRl
IDxsaW51eC9rdm1faG9zdC5oPgorI2luY2x1ZGUgPGxpbnV4L3NtcC5oPgorCisjaW5jbHVkZSAi
dnRpLmgiCisjaW5jbHVkZSAibWlzYy5oIgorCisjaW5jbHVkZSA8YXNtL3BhbC5oPgorI2luY2x1
ZGUgPGFzbS9zYWwuaD4KKyNpbmNsdWRlIDxhc20vdGxiLmg+CisKKy8qCisgKiBIYW5keSBtYWNy
b3MgdG8gbWFrZSBzdXJlIHRoYXQgdGhlIFBBTCByZXR1cm4gdmFsdWVzIHN0YXJ0IG91dAorICog
YXMgc29tZXRoaW5nIG1lYW5pbmdmdWwuCisgKi8KKyNkZWZpbmUgSU5JVF9QQUxfU1RBVFVTX1VO
SU1QTEVNRU5URUQoeCkJCVwKKwl7CQkJCQkJXAorCQl4LnN0YXR1cyA9IFBBTF9TVEFUVVNfVU5J
TVBMRU1FTlRFRDsJXAorCQl4LnYwID0gMDsJCQkJXAorCQl4LnYxID0gMDsJCQkJXAorCQl4LnYy
ID0gMDsJCQkJXAorCX0KKworI2RlZmluZSBJTklUX1BBTF9TVEFUVVNfU1VDQ0VTUyh4KQkJCVwK
Kwl7CQkJCQkJXAorCQl4LnN0YXR1cyA9IFBBTF9TVEFUVVNfU1VDQ0VTUzsJCVwKKwkJeC52MCA9
IDA7CQkJCVwKKwkJeC52MSA9IDA7CQkJCVwKKwkJeC52MiA9IDA7CQkJCVwKKyAgICB9CisKK3N0
YXRpYyB2b2lkIGt2bV9nZXRfcGFsX2NhbGxfZGF0YShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsCisJ
CXU2NCAqZ3IyOCwgdTY0ICpncjI5LCB1NjQgKmdyMzAsIHU2NCAqZ3IzMSkgeworCXN0cnVjdCBl
eGl0X2N0bF9kYXRhICpwOworCisJaWYgKHZjcHUpIHsKKwkJcCA9ICZ2Y3B1LT5hcmNoLmV4aXRf
ZGF0YTsKKwkJaWYgKHAtPmV4aXRfcmVhc29uID09IEVYSVRfUkVBU09OX1BBTF9DQUxMKSB7CisJ
CQkqZ3IyOCA9IHAtPnUucGFsX2RhdGEuZ3IyODsKKwkJCSpncjI5ID0gcC0+dS5wYWxfZGF0YS5n
cjI5OworCQkJKmdyMzAgPSBwLT51LnBhbF9kYXRhLmdyMzA7CisJCQkqZ3IzMSA9IHAtPnUucGFs
X2RhdGEuZ3IzMTsKKwkJCXJldHVybiA7CisJCX0KKwl9CisJcHJpbnRrKEtFUk5fREVCVUciRXJy
b3Igb2NjdXJzIGluIGt2bV9nZXRfcGFsX2NhbGxfZGF0YSEhXG4iKTsKK30KKworc3RhdGljIHZv
aWQgc2V0X3BhbF9yZXN1bHQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LAorCQlzdHJ1Y3QgaWE2NF9w
YWxfcmV0dmFsIHJlc3VsdCkgeworCisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnA7CisKKwlwID0g
a3ZtX2dldF9leGl0X2RhdGEodmNwdSk7CisJaWYgKHAgJiYgcC0+ZXhpdF9yZWFzb24gPT0gRVhJ
VF9SRUFTT05fUEFMX0NBTEwpIHsKKwkJcC0+dS5wYWxfZGF0YS5yZXQgPSByZXN1bHQ7CisJCXJl
dHVybiA7CisJfQorCUlOSVRfUEFMX1NUQVRVU19VTklNUExFTUVOVEVEKHAtPnUucGFsX2RhdGEu
cmV0KTsKK30KKworc3RhdGljIHZvaWQgc2V0X3NhbF9yZXN1bHQoc3RydWN0IGt2bV92Y3B1ICp2
Y3B1LAorCQlzdHJ1Y3Qgc2FsX3JldF92YWx1ZXMgcmVzdWx0KSB7CisJc3RydWN0IGV4aXRfY3Rs
X2RhdGEgKnA7CisKKwlwID0ga3ZtX2dldF9leGl0X2RhdGEodmNwdSk7CisJaWYgKHAgJiYgcC0+
ZXhpdF9yZWFzb24gPT0gRVhJVF9SRUFTT05fU0FMX0NBTEwpIHsKKwkJcC0+dS5zYWxfZGF0YS5y
ZXQgPSByZXN1bHQ7CisJCXJldHVybiA7CisJfQorCXByaW50ayhLRVJOX1dBUk5JTkciRXJyb3Ig
b2NjdXJzISEhXG4iKTsKK30KKworc3RydWN0IGNhY2hlX2ZsdXNoX2FyZ3MgeworCXU2NCBjYWNo
ZV90eXBlOworCXU2NCBvcGVyYXRpb247CisJdTY0IHByb2dyZXNzOworCWxvbmcgc3RhdHVzOwor
fTsKKworY3B1bWFza190IGNwdV9jYWNoZV9jb2hlcmVudF9tYXA7CisKK3N0YXRpYyB2b2lkIHJl
bW90ZV9wYWxfY2FjaGVfZmx1c2godm9pZCAqZGF0YSkKK3sKKwlzdHJ1Y3QgY2FjaGVfZmx1c2hf
YXJncyAqYXJncyA9IGRhdGE7CisJbG9uZyBzdGF0dXM7CisJdTY0IHByb2dyZXNzID0gYXJncy0+
cHJvZ3Jlc3M7CisKKwlzdGF0dXMgPSBpYTY0X3BhbF9jYWNoZV9mbHVzaChhcmdzLT5jYWNoZV90
eXBlLCBhcmdzLT5vcGVyYXRpb24sCisJCQkJCSZwcm9ncmVzcywgTlVMTCk7CisJaWYgKHN0YXR1
cyAhPSAwKQorCWFyZ3MtPnN0YXR1cyA9IHN0YXR1czsKK30KKworc3RhdGljIHN0cnVjdCBpYTY0
X3BhbF9yZXR2YWwgcGFsX2NhY2hlX2ZsdXNoKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwl1
NjQgZ3IyOCwgZ3IyOSwgZ3IzMCwgZ3IzMTsKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3Vs
dCA9IHswLCAwLCAwLCAwfTsKKwlzdHJ1Y3QgY2FjaGVfZmx1c2hfYXJncyBhcmdzID0gezAsIDAs
IDAsIDB9OworCWxvbmcgcHNyOworCisJZ3IyOCA9IGdyMjkgPSBncjMwID0gZ3IzMSA9IDA7CisJ
a3ZtX2dldF9wYWxfY2FsbF9kYXRhKHZjcHUsICZncjI4LCAmZ3IyOSwgJmdyMzAsICZncjMxKTsK
KworCWlmIChncjMxICE9IDApCisJCXByaW50ayhLRVJOX0VSUiJ2Y3B1OiVwIGNhbGxlZCBjYWNo
ZV9mbHVzaCBlcnJvciFcbiIsIHZjcHUpOworCisJLyogQWx3YXlzIGNhbGwgSG9zdCBQYWwgaW4g
aW50PTEgKi8KKwlncjMwICY9IH5QQUxfQ0FDSEVfRkxVU0hfQ0hLX0lOVFJTOworCWFyZ3MuY2Fj
aGVfdHlwZSA9IGdyMjk7CisJYXJncy5vcGVyYXRpb24gPSBncjMwOworCXNtcF9jYWxsX2Z1bmN0
aW9uKHJlbW90ZV9wYWxfY2FjaGVfZmx1c2gsCisJCQkJKHZvaWQgKikmYXJncywgMSwgMSk7CisJ
aWYgKGFyZ3Muc3RhdHVzICE9IDApCisJCXByaW50ayhLRVJOX0VSUiJwYWxfY2FjaGVfZmx1c2gg
ZXJyb3IhLCIKKwkJCQkic3RhdHVzOjB4JWx4XG4iLCBhcmdzLnN0YXR1cyk7CisJLyoKKwkgKiBD
YWxsIEhvc3QgUEFMIGNhY2hlIGZsdXNoCisJICogQ2xlYXIgcHNyLmljIHdoZW4gY2FsbCBQQUxf
Q0FDSEVfRkxVU0gKKwkgKi8KKwlsb2NhbF9pcnFfc2F2ZShwc3IpOworCXJlc3VsdC5zdGF0dXMg
PSBpYTY0X3BhbF9jYWNoZV9mbHVzaChncjI5LCBncjMwLCAmcmVzdWx0LnYxLAorCQkJCQkJJnJl
c3VsdC52MCk7CisJbG9jYWxfaXJxX3Jlc3RvcmUocHNyKTsKKwlpZiAocmVzdWx0LnN0YXR1cyAh
PSAwKQorCQlwcmludGsoS0VSTl9FUlIidmNwdTolcCBjcmFzaGVkIGR1ZSB0byBjYWNoZV9mbHVz
aCBlcnI6JWxkIgorCQkJCSJpbjE6JWx4LGluMjolbHhcbiIsCisJCQkJdmNwdSwgcmVzdWx0LnN0
YXR1cywgZ3IyOSwgZ3IzMCk7CisKKyNpZiAwCisJaWYgKGdyMjkgPT0gUEFMX0NBQ0hFX1RZUEVf
Q09IRVJFTlQpIHsKKwkJY3B1c19zZXRhbGwodmNwdS0+YXJjaC5jYWNoZV9jb2hlcmVudF9tYXAp
OworCQljcHVfY2xlYXIodmNwdS0+Y3B1LCB2Y3B1LT5hcmNoLmNhY2hlX2NvaGVyZW50X21hcCk7
CisJCWNwdXNfc2V0YWxsKGNwdV9jYWNoZV9jb2hlcmVudF9tYXApOworCQljcHVfY2xlYXIodmNw
dS0+Y3B1LCBjcHVfY2FjaGVfY29oZXJlbnRfbWFwKTsKKwl9CisjZW5kaWYKKwlyZXR1cm4gcmVz
dWx0OworfQorCitzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9jYWNoZV9zdW1tYXJ5KHN0cnVj
dCBrdm1fdmNwdSAqdmNwdSkKK3sKKworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0Owor
CisJUEFMX0NBTEwocmVzdWx0LCBQQUxfQ0FDSEVfU1VNTUFSWSwgMCwgMCwgMCk7CisJcmV0dXJu
IHJlc3VsdDsKK30KKworc3RhdGljIHN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX2ZyZXFfYmFz
ZShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJl
c3VsdDsKKworCVBBTF9DQUxMKHJlc3VsdCwgUEFMX0ZSRVFfQkFTRSwgMCwgMCwgMCk7CisKKwkv
KgorCSAqIFBBTF9GUkVRX0JBU0UgbWF5IG5vdCBiZSBpbXBsZW1lbnRlZCBpbiBzb21lIHBsYXRm
b3JtcywKKwkgKiBjYWxsIFNBTCBpbnN0ZWFkLgorCSAqLworCWlmIChyZXN1bHQudjAgPT0gMCkg
eworCQlyZXN1bHQuc3RhdHVzID0gaWE2NF9zYWxfZnJlcV9iYXNlKFNBTF9GUkVRX0JBU0VfUExB
VEZPUk0sCisJCQkJCQkJJnJlc3VsdC52MCwKKwkJCQkJCQkmcmVzdWx0LnYxKTsKKwkJcmVzdWx0
LnYyID0gMDsKKwl9CisKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMgc3RydWN0IGlhNjRf
cGFsX3JldHZhbCBwYWxfZnJlcV9yYXRpb3Moc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCisJ
c3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisKKwlQQUxfQ0FMTChyZXN1bHQsIFBBTF9G
UkVRX1JBVElPUywgMCwgMCwgMCk7CisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHN0cnVj
dCBpYTY0X3BhbF9yZXR2YWwgcGFsX2xvZ2ljYWxfdG9fcGh5c2ljYShzdHJ1Y3Qga3ZtX3ZjcHUg
KnZjcHUpCit7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisKKwlJTklUX1BBTF9T
VEFUVVNfVU5JTVBMRU1FTlRFRChyZXN1bHQpOworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRp
YyBzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9wbGF0Zm9ybV9hZGRyKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkKK3sKKworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCisJSU5JVF9Q
QUxfU1RBVFVTX1NVQ0NFU1MocmVzdWx0KTsKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMg
c3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfcHJvY19nZXRfZmVhdHVyZXMoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KQoreworCisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQgPSB7MCwgMCwg
MCwgMH07CisJbG9uZyBpbjAsIGluMSwgaW4yLCBpbjM7CisKKwlrdm1fZ2V0X3BhbF9jYWxsX2Rh
dGEodmNwdSwgJmluMCwgJmluMSwgJmluMiwgJmluMyk7CisJcmVzdWx0LnN0YXR1cyA9IGlhNjRf
cGFsX3Byb2NfZ2V0X2ZlYXR1cmVzKCZyZXN1bHQudjAsICZyZXN1bHQudjEsCisJCQkmcmVzdWx0
LnYyLCBpbjIpOworCisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHN0cnVjdCBpYTY0X3Bh
bF9yZXR2YWwgcGFsX2NhY2hlX2luZm8oc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCisJcGFs
X2NhY2hlX2NvbmZpZ19pbmZvX3QgY2k7CisJbG9uZyBzdGF0dXM7CisJdW5zaWduZWQgbG9uZyBp
bjAsIGluMSwgaW4yLCBpbjMsIHI5LCByMTA7CisKKwlrdm1fZ2V0X3BhbF9jYWxsX2RhdGEodmNw
dSwgJmluMCwgJmluMSwgJmluMiwgJmluMyk7CisJc3RhdHVzID0gaWE2NF9wYWxfY2FjaGVfY29u
ZmlnX2luZm8oaW4xLCBpbjIsICZjaSk7CisJcjkgPSBjaS5wY2NpX2luZm9fMS5wY2NpMV9kYXRh
OworCXIxMCA9IGNpLnBjY2lfaW5mb18yLnBjY2kyX2RhdGE7CisJcmV0dXJuICgoc3RydWN0IGlh
NjRfcGFsX3JldHZhbCl7c3RhdHVzLCByOSwgcjEwLCAwfSk7Cit9CisKKyNkZWZpbmUgR1VFU1Rf
SU1QTF9WQV9NU0IJNTkKKyNkZWZpbmUgR1VFU1RfUklEX0JJVFMJCTE4CisKK3N0YXRpYyBzdHJ1
Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF92bV9zdW1tYXJ5KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkK
K3sKKworCXBhbF92bV9pbmZvXzFfdV90IHZtaW5mbzE7CisJcGFsX3ZtX2luZm9fMl91X3Qgdm1p
bmZvMjsKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKworCVBBTF9DQUxMKHJlc3Vs
dCwgUEFMX1ZNX1NVTU1BUlksIDAsIDAsIDApOworCWlmICghcmVzdWx0LnN0YXR1cykgeworCQl2
bWluZm8xLnB2aTFfdmFsID0gcmVzdWx0LnYwOworCQl2bWluZm8xLnBhbF92bV9pbmZvXzFfcy5t
YXhfaXRyX2VudHJ5ID0gODsKKwkJdm1pbmZvMS5wYWxfdm1faW5mb18xX3MubWF4X2R0cl9lbnRy
eSA9IDg7CisJCXJlc3VsdC52MCA9IHZtaW5mbzEucHZpMV92YWw7CisJCXZtaW5mbzIucGFsX3Zt
X2luZm9fMl9zLmltcGxfdmFfbXNiID0gR1VFU1RfSU1QTF9WQV9NU0I7CisJCXZtaW5mbzIucGFs
X3ZtX2luZm9fMl9zLnJpZF9zaXplID0gR1VFU1RfUklEX0JJVFM7CisJCXJlc3VsdC52MSA9IHZt
aW5mbzIucHZpMl92YWw7CisJfQorCisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHN0cnVj
dCBpYTY0X3BhbF9yZXR2YWwgcGFsX3ZtX2luZm8oc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQorewor
CXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCisJSU5JVF9QQUxfU1RBVFVTX1VOSU1Q
TEVNRU5URUQocmVzdWx0KTsKKworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyAgdTY0IGt2
bV9nZXRfcGFsX2NhbGxfaW5kZXgoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCXU2NCBpbmRl
eCA9IDA7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnA7CisKKwlwID0ga3ZtX2dldF9leGl0X2Rh
dGEodmNwdSk7CisJaWYgKHAgJiYgKHAtPmV4aXRfcmVhc29uID09IEVYSVRfUkVBU09OX1BBTF9D
QUxMKSkgeworCQlpbmRleCA9IHAtPnUucGFsX2RhdGEuZ3IyODsKKwl9CisJcmV0dXJuIGluZGV4
OworfQorCitpbnQga3ZtX3BhbF9lbXVsKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2
bV9ydW4gKnJ1bikKK3sKKworCXU2NCBncjI4OworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVz
dWx0OworCWludCByZXQgPSAxOworCisJZ3IyOCA9IGt2bV9nZXRfcGFsX2NhbGxfaW5kZXgodmNw
dSk7CisJLypwcmludGsoInBhbF9jYWxsIGluZGV4OiVseFxuIixncjI4KTsqLworCXN3aXRjaCAo
Z3IyOCkgeworCWNhc2UgUEFMX0NBQ0hFX0ZMVVNIOgorCQlyZXN1bHQgPSBwYWxfY2FjaGVfZmx1
c2godmNwdSk7CisJCWJyZWFrOworCWNhc2UgUEFMX0NBQ0hFX1NVTU1BUlk6CisJCXJlc3VsdCA9
IHBhbF9jYWNoZV9zdW1tYXJ5KHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9IQUxUX0xJR0hU
OgorCXsKKwkJdmNwdS0+YXJjaC50aW1lcl9wZW5kaW5nID0gMTsKKwkJSU5JVF9QQUxfU1RBVFVT
X1NVQ0NFU1MocmVzdWx0KTsKKwkJaWYgKGt2bV9oaWdoZXN0X3BlbmRpbmdfaXJxKHZjcHUpID09
IC0xKSB7CisJCQlyZXQgPSBrdm1fZW11bGF0ZV9oYWx0KHZjcHUpOworCQl9CisJfQorCQlicmVh
azsKKworCWNhc2UgUEFMX0ZSRVFfUkFUSU9TOgorCQlyZXN1bHQgPSBwYWxfZnJlcV9yYXRpb3Mo
dmNwdSk7CisJCWJyZWFrOworCisJY2FzZSBQQUxfRlJFUV9CQVNFOgorCQlyZXN1bHQgPSBwYWxf
ZnJlcV9iYXNlKHZjcHUpOworCQlicmVhazsKKworCWNhc2UgUEFMX0xPR0lDQUxfVE9fUEhZU0lD
QUwgOgorCQlyZXN1bHQgPSBwYWxfbG9naWNhbF90b19waHlzaWNhKHZjcHUpOworCQlicmVhazsK
KworCWNhc2UgUEFMX1ZNX1NVTU1BUlkgOgorCQlyZXN1bHQgPSBwYWxfdm1fc3VtbWFyeSh2Y3B1
KTsKKwkJYnJlYWs7CisKKwljYXNlIFBBTF9WTV9JTkZPIDoKKwkJcmVzdWx0ID0gcGFsX3ZtX2lu
Zm8odmNwdSk7CisJCWJyZWFrOworCWNhc2UgUEFMX1BMQVRGT1JNX0FERFIgOgorCQlyZXN1bHQg
PSBwYWxfcGxhdGZvcm1fYWRkcih2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfQ0FDSEVfSU5G
TzoKKwkJcmVzdWx0ID0gcGFsX2NhY2hlX2luZm8odmNwdSk7CisJCWJyZWFrOworCWNhc2UgUEFM
X1BUQ0VfSU5GTzoKKwkJSU5JVF9QQUxfU1RBVFVTX1NVQ0NFU1MocmVzdWx0KTsKKwkJcmVzdWx0
LnYxID0gKDFMIDw8IDMyKSB8IDFMOworCQlicmVhazsKKwljYXNlIFBBTF9WTV9QQUdFX1NJWkU6
CisJCXJlc3VsdC5zdGF0dXMgPSBpYTY0X3BhbF92bV9wYWdlX3NpemUoJnJlc3VsdC52MCwKKwkJ
CQkJCQkmcmVzdWx0LnYxKTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfUlNFX0lORk86CisJCXJlc3Vs
dC5zdGF0dXMgPSBpYTY0X3BhbF9yc2VfaW5mbygmcmVzdWx0LnYwLAorCQkJCQkocGFsX2hpbnRz
X3VfdCAqKSZyZXN1bHQudjEpOworCQlicmVhazsKKwljYXNlIFBBTF9QUk9DX0dFVF9GRUFUVVJF
UzoKKwkJcmVzdWx0ID0gcGFsX3Byb2NfZ2V0X2ZlYXR1cmVzKHZjcHUpOworCQlicmVhazsKKwlj
YXNlIFBBTF9ERUJVR19JTkZPOgorCQlyZXN1bHQuc3RhdHVzID0gaWE2NF9wYWxfZGVidWdfaW5m
bygmcmVzdWx0LnYwLAorCQkJCQkJCSZyZXN1bHQudjEpOworCQlicmVhazsKKwljYXNlIFBBTF9W
RVJTSU9OOgorCQlyZXN1bHQuc3RhdHVzID0gaWE2NF9wYWxfdmVyc2lvbigKKwkJCQkocGFsX3Zl
cnNpb25fdV90ICopJnJlc3VsdC52MCwKKwkJCQkocGFsX3ZlcnNpb25fdV90ICopJnJlc3VsdC52
MSk7CisKKwkJYnJlYWs7CisJY2FzZSBQQUxfRklYRURfQUREUjoKKwkJcmVzdWx0LnN0YXR1cyA9
IFBBTF9TVEFUVVNfU1VDQ0VTUzsKKwkJcmVzdWx0LnYwID0gdmNwdS0+dmNwdV9pZDsKKwkJYnJl
YWs7CisJZGVmYXVsdDoKKwkJSU5JVF9QQUxfU1RBVFVTX1VOSU1QTEVNRU5URUQocmVzdWx0KTsK
KwkJcHJpbnRrKEtFUk5fV0FSTklORyJrdm06IFVuc3VwcG9ydGVkIHBhbCBjYWxsLCIKKwkJCQkJ
IiBpbmRleDoweCVseFxuIiwgZ3IyOCk7CisJfQorCXNldF9wYWxfcmVzdWx0KHZjcHUsIHJlc3Vs
dCk7CisJcmV0dXJuIHJldDsKK30KKworc3RhdGljIHN0cnVjdCBzYWxfcmV0X3ZhbHVlcyBzYWxf
ZW11bGF0b3Ioc3RydWN0IGt2bSAqa3ZtLAorCQkJCWxvbmcgaW5kZXgsIHVuc2lnbmVkIGxvbmcg
aW4xLAorCQkJCXVuc2lnbmVkIGxvbmcgaW4yLCB1bnNpZ25lZCBsb25nIGluMywKKwkJCQl1bnNp
Z25lZCBsb25nIGluNCwgdW5zaWduZWQgbG9uZyBpbjUsCisJCQkJdW5zaWduZWQgbG9uZyBpbjYs
IHVuc2lnbmVkIGxvbmcgaW43KQoreworCXVuc2lnbmVkIGxvbmcgcjkgID0gMDsKKwl1bnNpZ25l
ZCBsb25nIHIxMCA9IDA7CisJbG9uZyByMTEgPSAwOworCWxvbmcgc3RhdHVzOworCisJc3RhdHVz
ID0gMDsKKwlzd2l0Y2ggKGluZGV4KSB7CisJY2FzZSBTQUxfRlJFUV9CQVNFOgorCQlzdGF0dXMg
PSBpYTY0X3NhbF9mcmVxX2Jhc2UoaW4xLCAmcjksICZyMTApOworCQlicmVhazsKKwljYXNlIFNB
TF9QQ0lfQ09ORklHX1JFQUQ6CisJCXByaW50ayhLRVJOX1dBUk5JTkcia3ZtOiBOb3QgYWxsb3dl
ZCB0byBjYWxsIGhlcmUhIgorCQkJIiBTQUxfUENJX0NPTkZJR19SRUFEXG4iKTsKKwkJYnJlYWs7
CisJY2FzZSBTQUxfUENJX0NPTkZJR19XUklURToKKwkJcHJpbnRrKEtFUk5fV0FSTklORyJrdm06
IE5vdCBhbGxvd2VkIHRvIGNhbGwgaGVyZSEiCisJCQkiIFNBTF9QQ0lfQ09ORklHX1dSSVRFXG4i
KTsKKwkJYnJlYWs7CisJY2FzZSBTQUxfU0VUX1ZFQ1RPUlM6CisJCWlmIChpbjEgPT0gU0FMX1ZF
Q1RPUl9PU19CT09UX1JFTkRFWikgeworCQkJaWYgKGluNCAhPSAwIHx8IGluNSAhPSAwIHx8IGlu
NiAhPSAwIHx8IGluNyAhPSAwKSB7CisJCQkJc3RhdHVzID0gLTI7CisJCQl9IGVsc2UgeworCQkJ
CWt2bS0+YXJjaC5yZHZfc2FsX2RhdGEuYm9vdF9pcCA9IGluMjsKKwkJCQlrdm0tPmFyY2gucmR2
X3NhbF9kYXRhLmJvb3RfZ3AgPSBpbjM7CisJCQl9CisJCQlwcmludGsoIlJlbmR2b3VzIGNhbGxl
ZCEgaWlwOiVseFxuXG4iLCBpbjIpOworCQl9IGVsc2UKKwkJCXByaW50ayhLRVJOX1dBUk5JTkci
a3ZtOiBDQUxMRUQgU0FMX1NFVF9WRUNUT1JTICVsdS4iCisJCQkJCQkJImlnbm9yZWQuLi5cbiIs
IGluMSk7CisJCWJyZWFrOworCWNhc2UgU0FMX0dFVF9TVEFURV9JTkZPOgorCQkvKiBObyBtb3Jl
IGluZm8uICAqLworCQlzdGF0dXMgPSAtNTsKKwkJcjkgPSAwOworCQlicmVhazsKKwljYXNlIFNB
TF9HRVRfU1RBVEVfSU5GT19TSVpFOgorCQkvKiBSZXR1cm4gYSBkdW1teSBzaXplLiAgKi8KKwkJ
c3RhdHVzID0gMDsKKwkJcjkgPSAxMjg7CisJCWJyZWFrOworCWNhc2UgU0FMX0NMRUFSX1NUQVRF
X0lORk86CisJCS8qIE5vb3AuICAqLworCQlicmVhazsKKwljYXNlIFNBTF9NQ19SRU5ERVo6CisJ
CXByaW50ayhLRVJOX1dBUk5JTkcKKwkJCSJrdm06IGNhbGxlZCBTQUxfTUNfUkVOREVaLiBpZ25v
cmVkLi4uXG4iKTsKKwkJYnJlYWs7CisJY2FzZSBTQUxfTUNfU0VUX1BBUkFNUzoKKwkJcHJpbnRr
KEtFUk5fV0FSTklORworCQkJImt2bTogY2FsbGVkICBTQUxfTUNfU0VUX1BBUkFNUy5pZ25vcmVk
IVxuIik7CisJCWJyZWFrOworCWNhc2UgU0FMX0NBQ0hFX0ZMVVNIOgorCQlpZiAoMSkgeworCQkJ
LypGbHVzaCB1c2luZyBTQUwuCisJCQlUaGlzIG1ldGhvZCBpcyBmYXN0ZXIgYnV0IGhhcyBhIHNp
ZGUKKwkJCWVmZmVjdCBvbiBvdGhlciB2Y3B1IHJ1bm5pbmcgb24KKwkJCXRoaXMgY3B1LiAgKi8K
KwkJCXN0YXR1cyA9IGlhNjRfc2FsX2NhY2hlX2ZsdXNoKGluMSk7CisJCX0gZWxzZSB7CisJCQkv
Kk1heWJlIG5lZWQgdG8gaW1wbGVtZW50IHRoZSBtZXRob2QKKwkJCXdpdGhvdXQgc2lkZSBlZmZl
Y3QhKi8KKwkJCXN0YXR1cyA9IDA7CisJCX0KKwkJYnJlYWs7CisJY2FzZSBTQUxfQ0FDSEVfSU5J
VDoKKwkJcHJpbnRrKEtFUk5fV0FSTklORworCQkJImt2bTogY2FsbGVkIFNBTF9DQUNIRV9JTklU
LiAgaWdub3JlZC4uLlxuIik7CisJCWJyZWFrOworCWNhc2UgU0FMX1VQREFURV9QQUw6CisJCXBy
aW50ayhLRVJOX1dBUk5JTkcKKwkJCSJrdm06IENBTExFRCBTQUxfVVBEQVRFX1BBTC4gIGlnbm9y
ZWQuLi5cbiIpOworCQlicmVhazsKKwlkZWZhdWx0OgorCQlwcmludGsoS0VSTl9XQVJOSU5HImt2
bTogY2FsbGVkIFNBTF9DQUxMIHdpdGggdW5rbm93biBpbmRleC4iCisJCQkJCQkiIGluZGV4OiVs
ZFxuIiwgaW5kZXgpOworCQlzdGF0dXMgPSAtMTsKKwkJYnJlYWs7CisJfQorCXJldHVybiAoKHN0
cnVjdCBzYWxfcmV0X3ZhbHVlcykge3N0YXR1cywgcjksIHIxMCwgcjExfSk7Cit9CisKK3N0YXRp
YyB2b2lkIGt2bV9nZXRfc2FsX2NhbGxfZGF0YShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsIHU2NCAq
aW4wLCB1NjQgKmluMSwKKwkJdTY0ICppbjIsIHU2NCAqaW4zLCB1NjQgKmluNCwgdTY0ICppbjUs
IHU2NCAqaW42LCB1NjQgKmluNyl7CisKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcDsKKworCXAg
PSBrdm1fZ2V0X2V4aXRfZGF0YSh2Y3B1KTsKKworCWlmIChwKSB7CisJCWlmIChwLT5leGl0X3Jl
YXNvbiA9PSBFWElUX1JFQVNPTl9TQUxfQ0FMTCkgeworCQkJKmluMCA9IHAtPnUuc2FsX2RhdGEu
aW4wOworCQkJKmluMSA9IHAtPnUuc2FsX2RhdGEuaW4xOworCQkJKmluMiA9IHAtPnUuc2FsX2Rh
dGEuaW4yOworCQkJKmluMyA9IHAtPnUuc2FsX2RhdGEuaW4zOworCQkJKmluNCA9IHAtPnUuc2Fs
X2RhdGEuaW40OworCQkJKmluNSA9IHAtPnUuc2FsX2RhdGEuaW41OworCQkJKmluNiA9IHAtPnUu
c2FsX2RhdGEuaW42OworCQkJKmluNyA9IHAtPnUuc2FsX2RhdGEuaW43OworCQkJcmV0dXJuIDsK
KwkJfQorCX0KKwkqaW4wID0gMDsKK30KKwordm9pZCBrdm1fc2FsX2VtdWwoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KQoreworCisJc3RydWN0IHNhbF9yZXRfdmFsdWVzIHJlc3VsdDsKKwl1NjQgaW5k
ZXgsIGluMSwgaW4yLCBpbjMsIGluNCwgaW41LCBpbjYsIGluNzsKKworCWt2bV9nZXRfc2FsX2Nh
bGxfZGF0YSh2Y3B1LCAmaW5kZXgsICZpbjEsICZpbjIsCisJCQkmaW4zLCAmaW40LCAmaW41LCAm
aW42LCAmaW43KTsKKwlyZXN1bHQgPSBzYWxfZW11bGF0b3IodmNwdS0+a3ZtLCBpbmRleCwgaW4x
LCBpbjIsIGluMywKKwkJCQkJaW40LCBpbjUsIGluNiwgaW43KTsKKwlzZXRfc2FsX3Jlc3VsdCh2
Y3B1LCByZXN1bHQpOworfQotLSAKMS41LjIKCg==

------_=_NextPart_001_01C89309.9CF3682F--
