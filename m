From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:16 +0000
Subject: [PATCH][07] Add kvm sal/pal virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FCA@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.21BC202F"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.21BC202F
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 13:15:05 +0800
Subject: [PATCH] kvm/ia64: Add kvm sal/pal virtulization support.

Some sal/pal calls would be traped to kvm for virtulization
from guest firmware.
Signed-off-by: Xiantao Zhang<xiantao.zhang@intel.com>
---
 arch/ia64/kvm/kvm_fw.c |  500
++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 500 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/kvm_fw.c

diff --git a/arch/ia64/kvm/kvm_fw.c b/arch/ia64/kvm/kvm_fw.c
new file mode 100644
index 0000000..e6f9f29
--- /dev/null
+++ b/arch/ia64/kvm/kvm_fw.c
@@ -0,0 +1,500 @@
+/*
+ * PAL/SAL call delegation
+ *
+ * Copyright (c) 2004 Li Susie <susie.li@intel.com>
+ * Copyright (c) 2005 Yu Ke <ke.yu@intel.com>
+ * Copyright (c) 2007 Zhang Xiantao <xiantao.zhang@intel.com>
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
+		if (kvm_highest_pending_irq(vcpu) =3D=3D -1) {
+			ret =3D kvm_emulate_halt(vcpu);
+		}
+		vcpu->arch.timer_pending =3D 1;
+		INIT_PAL_STATUS_SUCCESS(result);
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
1.5.1

------_=_NextPart_001_01C863F4.21BC202F
Content-Type: application/octet-stream;
	name="0007-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0007-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch
Content-Disposition: attachment;
	filename="0007-kvm-ia64-Add-kvm-sal-pal-virtulization-support.patch"

RnJvbSA5MTdjNTQyYjA3NTFlYjY5MzE1ZjU5YTk0MDJhNjU3YjA4Zjc5NzA3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxMzoxNTowNSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQga3ZtIHNhbC9wYWwgdmlydHVsaXphdGlvbiBzdXBwb3J0LgoKU29tZSBz
YWwvcGFsIGNhbGxzIHdvdWxkIGJlIHRyYXBlZCB0byBrdm0gZm9yIHZpcnR1bGl6YXRpb24KZnJv
bSBndWVzdCBmaXJtd2FyZS4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZzx4aWFudGFvLnpo
YW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL2t2bV9mdy5jIHwgIDUwMCArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdl
ZCwgNTAwIGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQg
YXJjaC9pYTY0L2t2bS9rdm1fZncuYwoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0va3ZtX2Z3
LmMgYi9hcmNoL2lhNjQva3ZtL2t2bV9mdy5jCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAw
MDAwMDAuLmU2ZjlmMjkKLS0tIC9kZXYvbnVsbAorKysgYi9hcmNoL2lhNjQva3ZtL2t2bV9mdy5j
CkBAIC0wLDAgKzEsNTAwIEBACisvKgorICogUEFML1NBTCBjYWxsIGRlbGVnYXRpb24KKyAqCisg
KiBDb3B5cmlnaHQgKGMpIDIwMDQgTGkgU3VzaWUgPHN1c2llLmxpQGludGVsLmNvbT4KKyAqIENv
cHlyaWdodCAoYykgMjAwNSBZdSBLZSA8a2UueXVAaW50ZWwuY29tPgorICogQ29weXJpZ2h0IChj
KSAyMDA3IFpoYW5nIFhpYW50YW8gPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgorICoKKyAqIFRo
aXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQv
b3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2YgdGhlIEdO
VSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAyLCBhcyBwdWJsaXNoZWQgYnkg
dGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZGlz
dHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWwsIGJ1dCBXSVRIT1VUCisgKiBB
TlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJyYW50eSBvZiBNRVJDSEFO
VEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NFLiAgU2VlIHRo
ZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1vcmUgZGV0YWlscy4KKyAqCisg
KiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJs
aWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07IGlmIG5vdCwgd3JpdGUgdG8g
dGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkgVGVtcGxlCisgKiBQbGFjZSAt
IFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4KKyAqLworCisjaW5jbHVkZSA8
bGludXgva3ZtX2hvc3QuaD4KKyNpbmNsdWRlIDxsaW51eC9zbXAuaD4KKworI2luY2x1ZGUgInZ0
aS5oIgorI2luY2x1ZGUgIm1pc2MuaCIKKworI2luY2x1ZGUgPGFzbS9wYWwuaD4KKyNpbmNsdWRl
IDxhc20vc2FsLmg+CisjaW5jbHVkZSA8YXNtL3RsYi5oPgorCisvKgorICogSGFuZHkgbWFjcm9z
IHRvIG1ha2Ugc3VyZSB0aGF0IHRoZSBQQUwgcmV0dXJuIHZhbHVlcyBzdGFydCBvdXQKKyAqIGFz
IHNvbWV0aGluZyBtZWFuaW5nZnVsLgorICovCisjZGVmaW5lIElOSVRfUEFMX1NUQVRVU19VTklN
UExFTUVOVEVEKHgpCQlcCisJewkJCQkJCVwKKwkJeC5zdGF0dXMgPSBQQUxfU1RBVFVTX1VOSU1Q
TEVNRU5URUQ7CVwKKwkJeC52MCA9IDA7CQkJCVwKKwkJeC52MSA9IDA7CQkJCVwKKwkJeC52MiA9
IDA7CQkJCVwKKwl9CisKKyNkZWZpbmUgSU5JVF9QQUxfU1RBVFVTX1NVQ0NFU1MoeCkJCQlcCisJ
ewkJCQkJCVwKKwkJeC5zdGF0dXMgPSBQQUxfU1RBVFVTX1NVQ0NFU1M7CQlcCisJCXgudjAgPSAw
OwkJCQlcCisJCXgudjEgPSAwOwkJCQlcCisJCXgudjIgPSAwOwkJCQlcCisgICAgfQorCitzdGF0
aWMgdm9pZCBrdm1fZ2V0X3BhbF9jYWxsX2RhdGEoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LAorCQl1
NjQgKmdyMjgsIHU2NCAqZ3IyOSwgdTY0ICpncjMwLCB1NjQgKmdyMzEpIHsKKwlzdHJ1Y3QgZXhp
dF9jdGxfZGF0YSAqcDsKKworCWlmICh2Y3B1KSB7CisJCXAgPSAmdmNwdS0+YXJjaC5leGl0X2Rh
dGE7CisJCWlmIChwLT5leGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9QQUxfQ0FMTCkgeworCQkJ
KmdyMjggPSBwLT51LnBhbF9kYXRhLmdyMjg7CisJCQkqZ3IyOSA9IHAtPnUucGFsX2RhdGEuZ3Iy
OTsKKwkJCSpncjMwID0gcC0+dS5wYWxfZGF0YS5ncjMwOworCQkJKmdyMzEgPSBwLT51LnBhbF9k
YXRhLmdyMzE7CisJCQlyZXR1cm4gOworCQl9CisJfQorCXByaW50ayhLRVJOX0RFQlVHIkVycm9y
IG9jY3VycyBpbiBrdm1fZ2V0X3BhbF9jYWxsX2RhdGEhIVxuIik7Cit9CisKK3N0YXRpYyB2b2lk
IHNldF9wYWxfcmVzdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwKKwkJc3RydWN0IGlhNjRfcGFs
X3JldHZhbCByZXN1bHQpIHsKKworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwOworCisJcCA9IGt2
bV9nZXRfZXhpdF9kYXRhKHZjcHUpOworCWlmIChwICYmIHAtPmV4aXRfcmVhc29uID09IEVYSVRf
UkVBU09OX1BBTF9DQUxMKSB7CisJCXAtPnUucGFsX2RhdGEucmV0ID0gcmVzdWx0OworCQlyZXR1
cm4gOworCX0KKwlJTklUX1BBTF9TVEFUVVNfVU5JTVBMRU1FTlRFRChwLT51LnBhbF9kYXRhLnJl
dCk7Cit9CisKK3N0YXRpYyB2b2lkIHNldF9zYWxfcmVzdWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNw
dSwKKwkJc3RydWN0IHNhbF9yZXRfdmFsdWVzIHJlc3VsdCkgeworCXN0cnVjdCBleGl0X2N0bF9k
YXRhICpwOworCisJcCA9IGt2bV9nZXRfZXhpdF9kYXRhKHZjcHUpOworCWlmIChwICYmIHAtPmV4
aXRfcmVhc29uID09IEVYSVRfUkVBU09OX1NBTF9DQUxMKSB7CisJCXAtPnUuc2FsX2RhdGEucmV0
ID0gcmVzdWx0OworCQlyZXR1cm4gOworCX0KKwlwcmludGsoS0VSTl9XQVJOSU5HIkVycm9yIG9j
Y3VycyEhIVxuIik7Cit9CisKK3N0cnVjdCBjYWNoZV9mbHVzaF9hcmdzIHsKKwl1NjQgY2FjaGVf
dHlwZTsKKwl1NjQgb3BlcmF0aW9uOworCXU2NCBwcm9ncmVzczsKKwlsb25nIHN0YXR1czsKK307
CisKK2NwdW1hc2tfdCBjcHVfY2FjaGVfY29oZXJlbnRfbWFwOworCitzdGF0aWMgdm9pZCByZW1v
dGVfcGFsX2NhY2hlX2ZsdXNoKHZvaWQgKmRhdGEpCit7CisJc3RydWN0IGNhY2hlX2ZsdXNoX2Fy
Z3MgKmFyZ3MgPSBkYXRhOworCWxvbmcgc3RhdHVzOworCXU2NCBwcm9ncmVzcyA9IGFyZ3MtPnBy
b2dyZXNzOworCisJc3RhdHVzID0gaWE2NF9wYWxfY2FjaGVfZmx1c2goYXJncy0+Y2FjaGVfdHlw
ZSwgYXJncy0+b3BlcmF0aW9uLAorCQkJCQkmcHJvZ3Jlc3MsIE5VTEwpOworCWlmIChzdGF0dXMg
IT0gMCkKKwlhcmdzLT5zdGF0dXMgPSBzdGF0dXM7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaWE2NF9w
YWxfcmV0dmFsIHBhbF9jYWNoZV9mbHVzaChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJdTY0
IGdyMjgsIGdyMjksIGdyMzAsIGdyMzE7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQg
PSB7MCwgMCwgMCwgMH07CisJc3RydWN0IGNhY2hlX2ZsdXNoX2FyZ3MgYXJncyA9IHswLCAwLCAw
LCAwfTsKKwlsb25nIHBzcjsKKworCWdyMjggPSBncjI5ID0gZ3IzMCA9IGdyMzEgPSAwOworCWt2
bV9nZXRfcGFsX2NhbGxfZGF0YSh2Y3B1LCAmZ3IyOCwgJmdyMjksICZncjMwLCAmZ3IzMSk7CisK
KwlpZiAoZ3IzMSAhPSAwKQorCQlwcmludGsoS0VSTl9FUlIidmNwdTolcCBjYWxsZWQgY2FjaGVf
Zmx1c2ggZXJyb3IhXG4iLCB2Y3B1KTsKKworCS8qIEFsd2F5cyBjYWxsIEhvc3QgUGFsIGluIGlu
dD0xICovCisJZ3IzMCAmPSB+UEFMX0NBQ0hFX0ZMVVNIX0NIS19JTlRSUzsKKwlhcmdzLmNhY2hl
X3R5cGUgPSBncjI5OworCWFyZ3Mub3BlcmF0aW9uID0gZ3IzMDsKKwlzbXBfY2FsbF9mdW5jdGlv
bihyZW1vdGVfcGFsX2NhY2hlX2ZsdXNoLAorCQkJCSh2b2lkICopJmFyZ3MsIDEsIDEpOworCWlm
IChhcmdzLnN0YXR1cyAhPSAwKQorCQlwcmludGsoS0VSTl9FUlIicGFsX2NhY2hlX2ZsdXNoIGVy
cm9yISwiCisJCQkJInN0YXR1czoweCVseFxuIiwgYXJncy5zdGF0dXMpOworCS8qCisJICogQ2Fs
bCBIb3N0IFBBTCBjYWNoZSBmbHVzaAorCSAqIENsZWFyIHBzci5pYyB3aGVuIGNhbGwgUEFMX0NB
Q0hFX0ZMVVNICisJICovCisJbG9jYWxfaXJxX3NhdmUocHNyKTsKKwlyZXN1bHQuc3RhdHVzID0g
aWE2NF9wYWxfY2FjaGVfZmx1c2goZ3IyOSwgZ3IzMCwgJnJlc3VsdC52MSwKKwkJCQkJCSZyZXN1
bHQudjApOworCWxvY2FsX2lycV9yZXN0b3JlKHBzcik7CisJaWYgKHJlc3VsdC5zdGF0dXMgIT0g
MCkKKwkJcHJpbnRrKEtFUk5fRVJSInZjcHU6JXAgY3Jhc2hlZCBkdWUgdG8gY2FjaGVfZmx1c2gg
ZXJyOiVsZCIKKwkJCQkiaW4xOiVseCxpbjI6JWx4XG4iLAorCQkJCXZjcHUsIHJlc3VsdC5zdGF0
dXMsIGdyMjksIGdyMzApOworCisjaWYgMAorCWlmIChncjI5ID09IFBBTF9DQUNIRV9UWVBFX0NP
SEVSRU5UKSB7CisJCWNwdXNfc2V0YWxsKHZjcHUtPmFyY2guY2FjaGVfY29oZXJlbnRfbWFwKTsK
KwkJY3B1X2NsZWFyKHZjcHUtPmNwdSwgdmNwdS0+YXJjaC5jYWNoZV9jb2hlcmVudF9tYXApOwor
CQljcHVzX3NldGFsbChjcHVfY2FjaGVfY29oZXJlbnRfbWFwKTsKKwkJY3B1X2NsZWFyKHZjcHUt
PmNwdSwgY3B1X2NhY2hlX2NvaGVyZW50X21hcCk7CisJfQorI2VuZGlmCisJcmV0dXJuIHJlc3Vs
dDsKK30KKworc3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfY2FjaGVfc3VtbWFyeShzdHJ1Y3Qg
a3ZtX3ZjcHUgKnZjcHUpCit7CisKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKwor
CVBBTF9DQUxMKHJlc3VsdCwgUEFMX0NBQ0hFX1NVTU1BUlksIDAsIDAsIDApOworCXJldHVybiBy
ZXN1bHQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHBhbF9mcmVxX2Jhc2Uo
c3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1
bHQ7CisKKwlQQUxfQ0FMTChyZXN1bHQsIFBBTF9GUkVRX0JBU0UsIDAsIDAsIDApOworCisJLyoK
KwkgKiBQQUxfRlJFUV9CQVNFIG1heSBub3QgYmUgaW1wbGVtZW50ZWQgaW4gc29tZSBwbGF0Zm9y
bXMsCisJICogY2FsbCBTQUwgaW5zdGVhZC4KKwkgKi8KKwlpZiAocmVzdWx0LnYwID09IDApIHsK
KwkJcmVzdWx0LnN0YXR1cyA9IGlhNjRfc2FsX2ZyZXFfYmFzZShTQUxfRlJFUV9CQVNFX1BMQVRG
T1JNLAorCQkJCQkJCSZyZXN1bHQudjAsCisJCQkJCQkJJnJlc3VsdC52MSk7CisJCXJlc3VsdC52
MiA9IDA7CisJfQorCisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHN0cnVjdCBpYTY0X3Bh
bF9yZXR2YWwgcGFsX2ZyZXFfcmF0aW9zKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKworCXN0
cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCisJUEFMX0NBTEwocmVzdWx0LCBQQUxfRlJF
UV9SQVRJT1MsIDAsIDAsIDApOworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3Qg
aWE2NF9wYWxfcmV0dmFsIHBhbF9sb2dpY2FsX3RvX3BoeXNpY2Eoc3RydWN0IGt2bV92Y3B1ICp2
Y3B1KQoreworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0OworCisJSU5JVF9QQUxfU1RB
VFVTX1VOSU1QTEVNRU5URUQocmVzdWx0KTsKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMg
c3RydWN0IGlhNjRfcGFsX3JldHZhbCBwYWxfcGxhdGZvcm1fYWRkcihzdHJ1Y3Qga3ZtX3ZjcHUg
KnZjcHUpCit7CisKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKworCUlOSVRfUEFM
X1NUQVRVU19TVUNDRVNTKHJlc3VsdCk7CisJcmV0dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHN0
cnVjdCBpYTY0X3BhbF9yZXR2YWwgcGFsX3Byb2NfZ2V0X2ZlYXR1cmVzKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkKK3sKKworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgcmVzdWx0ID0gezAsIDAsIDAs
IDB9OworCWxvbmcgaW4wLCBpbjEsIGluMiwgaW4zOworCisJa3ZtX2dldF9wYWxfY2FsbF9kYXRh
KHZjcHUsICZpbjAsICZpbjEsICZpbjIsICZpbjMpOworCXJlc3VsdC5zdGF0dXMgPSBpYTY0X3Bh
bF9wcm9jX2dldF9mZWF0dXJlcygmcmVzdWx0LnYwLCAmcmVzdWx0LnYxLAorCQkJJnJlc3VsdC52
MiwgaW4yKTsKKworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3QgaWE2NF9wYWxf
cmV0dmFsIHBhbF9jYWNoZV9pbmZvKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKworCXBhbF9j
YWNoZV9jb25maWdfaW5mb190IGNpOworCWxvbmcgc3RhdHVzOworCXVuc2lnbmVkIGxvbmcgaW4w
LCBpbjEsIGluMiwgaW4zLCByOSwgcjEwOworCisJa3ZtX2dldF9wYWxfY2FsbF9kYXRhKHZjcHUs
ICZpbjAsICZpbjEsICZpbjIsICZpbjMpOworCXN0YXR1cyA9IGlhNjRfcGFsX2NhY2hlX2NvbmZp
Z19pbmZvKGluMSwgaW4yLCAmY2kpOworCXI5ID0gY2kucGNjaV9pbmZvXzEucGNjaTFfZGF0YTsK
KwlyMTAgPSBjaS5wY2NpX2luZm9fMi5wY2NpMl9kYXRhOworCXJldHVybiAoKHN0cnVjdCBpYTY0
X3BhbF9yZXR2YWwpe3N0YXR1cywgcjksIHIxMCwgMH0pOworfQorCisjZGVmaW5lIEdVRVNUX0lN
UExfVkFfTVNCCTU5CisjZGVmaW5lIEdVRVNUX1JJRF9CSVRTCQkxOAorCitzdGF0aWMgc3RydWN0
IGlhNjRfcGFsX3JldHZhbCBwYWxfdm1fc3VtbWFyeShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7
CisKKwlwYWxfdm1faW5mb18xX3VfdCB2bWluZm8xOworCXBhbF92bV9pbmZvXzJfdV90IHZtaW5m
bzI7CisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXN1bHQ7CisKKwlQQUxfQ0FMTChyZXN1bHQs
IFBBTF9WTV9TVU1NQVJZLCAwLCAwLCAwKTsKKwlpZiAoIXJlc3VsdC5zdGF0dXMpIHsKKwkJdm1p
bmZvMS5wdmkxX3ZhbCA9IHJlc3VsdC52MDsKKwkJdm1pbmZvMS5wYWxfdm1faW5mb18xX3MubWF4
X2l0cl9lbnRyeSA9IDg7CisJCXZtaW5mbzEucGFsX3ZtX2luZm9fMV9zLm1heF9kdHJfZW50cnkg
PSA4OworCQlyZXN1bHQudjAgPSB2bWluZm8xLnB2aTFfdmFsOworCQl2bWluZm8yLnBhbF92bV9p
bmZvXzJfcy5pbXBsX3ZhX21zYiA9IEdVRVNUX0lNUExfVkFfTVNCOworCQl2bWluZm8yLnBhbF92
bV9pbmZvXzJfcy5yaWRfc2l6ZSA9IEdVRVNUX1JJRF9CSVRTOworCQlyZXN1bHQudjEgPSB2bWlu
Zm8yLnB2aTJfdmFsOworCX0KKworCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3Qg
aWE2NF9wYWxfcmV0dmFsIHBhbF92bV9pbmZvKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwlz
dHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3VsdDsKKworCUlOSVRfUEFMX1NUQVRVU19VTklNUExF
TUVOVEVEKHJlc3VsdCk7CisKKwlyZXR1cm4gcmVzdWx0OworfQorCitzdGF0aWMgIHU2NCBrdm1f
Z2V0X3BhbF9jYWxsX2luZGV4KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwl1NjQgaW5kZXgg
PSAwOworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwOworCisJcCA9IGt2bV9nZXRfZXhpdF9kYXRh
KHZjcHUpOworCWlmIChwICYmIChwLT5leGl0X3JlYXNvbiA9PSBFWElUX1JFQVNPTl9QQUxfQ0FM
TCkpIHsKKwkJaW5kZXggPSBwLT51LnBhbF9kYXRhLmdyMjg7CisJfQorCXJldHVybiBpbmRleDsK
K30KKworaW50IGt2bV9wYWxfZW11bChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsIHN0cnVjdCBrdm1f
cnVuICpydW4pCit7CisKKwl1NjQgZ3IyODsKKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJlc3Vs
dDsKKwlpbnQgcmV0ID0gMTsKKworCWdyMjggPSBrdm1fZ2V0X3BhbF9jYWxsX2luZGV4KHZjcHUp
OworCS8qcHJpbnRrKCJwYWxfY2FsbCBpbmRleDolbHhcbiIsZ3IyOCk7Ki8KKwlzd2l0Y2ggKGdy
MjgpIHsKKwljYXNlIFBBTF9DQUNIRV9GTFVTSDoKKwkJcmVzdWx0ID0gcGFsX2NhY2hlX2ZsdXNo
KHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9DQUNIRV9TVU1NQVJZOgorCQlyZXN1bHQgPSBw
YWxfY2FjaGVfc3VtbWFyeSh2Y3B1KTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfSEFMVF9MSUdIVDoK
Kwl7CisJCWlmIChrdm1faGlnaGVzdF9wZW5kaW5nX2lycSh2Y3B1KSA9PSAtMSkgeworCQkJcmV0
ID0ga3ZtX2VtdWxhdGVfaGFsdCh2Y3B1KTsKKwkJfQorCQl2Y3B1LT5hcmNoLnRpbWVyX3BlbmRp
bmcgPSAxOworCQlJTklUX1BBTF9TVEFUVVNfU1VDQ0VTUyhyZXN1bHQpOworCX0KKwkJYnJlYWs7
CisKKwljYXNlIFBBTF9GUkVRX1JBVElPUzoKKwkJcmVzdWx0ID0gcGFsX2ZyZXFfcmF0aW9zKHZj
cHUpOworCQlicmVhazsKKworCWNhc2UgUEFMX0ZSRVFfQkFTRToKKwkJcmVzdWx0ID0gcGFsX2Zy
ZXFfYmFzZSh2Y3B1KTsKKwkJYnJlYWs7CisKKwljYXNlIFBBTF9MT0dJQ0FMX1RPX1BIWVNJQ0FM
IDoKKwkJcmVzdWx0ID0gcGFsX2xvZ2ljYWxfdG9fcGh5c2ljYSh2Y3B1KTsKKwkJYnJlYWs7CisK
KwljYXNlIFBBTF9WTV9TVU1NQVJZIDoKKwkJcmVzdWx0ID0gcGFsX3ZtX3N1bW1hcnkodmNwdSk7
CisJCWJyZWFrOworCisJY2FzZSBQQUxfVk1fSU5GTyA6CisJCXJlc3VsdCA9IHBhbF92bV9pbmZv
KHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9QTEFURk9STV9BRERSIDoKKwkJcmVzdWx0ID0g
cGFsX3BsYXRmb3JtX2FkZHIodmNwdSk7CisJCWJyZWFrOworCWNhc2UgUEFMX0NBQ0hFX0lORk86
CisJCXJlc3VsdCA9IHBhbF9jYWNoZV9pbmZvKHZjcHUpOworCQlicmVhazsKKwljYXNlIFBBTF9Q
VENFX0lORk86CisJCUlOSVRfUEFMX1NUQVRVU19TVUNDRVNTKHJlc3VsdCk7CisJCXJlc3VsdC52
MSA9ICgxTCA8PCAzMikgfCAxTDsKKwkJYnJlYWs7CisJY2FzZSBQQUxfVk1fUEFHRV9TSVpFOgor
CQlyZXN1bHQuc3RhdHVzID0gaWE2NF9wYWxfdm1fcGFnZV9zaXplKCZyZXN1bHQudjAsCisJCQkJ
CQkJJnJlc3VsdC52MSk7CisJCWJyZWFrOworCWNhc2UgUEFMX1JTRV9JTkZPOgorCQlyZXN1bHQu
c3RhdHVzID0gaWE2NF9wYWxfcnNlX2luZm8oJnJlc3VsdC52MCwKKwkJCQkJKHBhbF9oaW50c191
X3QgKikmcmVzdWx0LnYxKTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfUFJPQ19HRVRfRkVBVFVSRVM6
CisJCXJlc3VsdCA9IHBhbF9wcm9jX2dldF9mZWF0dXJlcyh2Y3B1KTsKKwkJYnJlYWs7CisJY2Fz
ZSBQQUxfREVCVUdfSU5GTzoKKwkJcmVzdWx0LnN0YXR1cyA9IGlhNjRfcGFsX2RlYnVnX2luZm8o
JnJlc3VsdC52MCwKKwkJCQkJCQkmcmVzdWx0LnYxKTsKKwkJYnJlYWs7CisJY2FzZSBQQUxfVkVS
U0lPTjoKKwkJcmVzdWx0LnN0YXR1cyA9IGlhNjRfcGFsX3ZlcnNpb24oCisJCQkJKHBhbF92ZXJz
aW9uX3VfdCAqKSZyZXN1bHQudjAsCisJCQkJKHBhbF92ZXJzaW9uX3VfdCAqKSZyZXN1bHQudjEp
OworCisJCWJyZWFrOworCWNhc2UgUEFMX0ZJWEVEX0FERFI6CisJCXJlc3VsdC5zdGF0dXMgPSBQ
QUxfU1RBVFVTX1NVQ0NFU1M7CisJCXJlc3VsdC52MCA9IHZjcHUtPnZjcHVfaWQ7CisJCWJyZWFr
OworCWRlZmF1bHQ6CisJCUlOSVRfUEFMX1NUQVRVU19VTklNUExFTUVOVEVEKHJlc3VsdCk7CisJ
CXByaW50ayhLRVJOX1dBUk5JTkcia3ZtOiBVbnN1cHBvcnRlZCBwYWwgY2FsbCwiCisJCQkJCSIg
aW5kZXg6MHglbHhcbiIsIGdyMjgpOworCX0KKwlzZXRfcGFsX3Jlc3VsdCh2Y3B1LCByZXN1bHQp
OworCXJldHVybiByZXQ7Cit9CisKK3N0YXRpYyBzdHJ1Y3Qgc2FsX3JldF92YWx1ZXMgc2FsX2Vt
dWxhdG9yKHN0cnVjdCBrdm0gKmt2bSwKKwkJCQlsb25nIGluZGV4LCB1bnNpZ25lZCBsb25nIGlu
MSwKKwkJCQl1bnNpZ25lZCBsb25nIGluMiwgdW5zaWduZWQgbG9uZyBpbjMsCisJCQkJdW5zaWdu
ZWQgbG9uZyBpbjQsIHVuc2lnbmVkIGxvbmcgaW41LAorCQkJCXVuc2lnbmVkIGxvbmcgaW42LCB1
bnNpZ25lZCBsb25nIGluNykKK3sKKwl1bnNpZ25lZCBsb25nIHI5ICA9IDA7CisJdW5zaWduZWQg
bG9uZyByMTAgPSAwOworCWxvbmcgcjExID0gMDsKKwlsb25nIHN0YXR1czsKKworCXN0YXR1cyA9
IDA7CisJc3dpdGNoIChpbmRleCkgeworCWNhc2UgU0FMX0ZSRVFfQkFTRToKKwkJc3RhdHVzID0g
aWE2NF9zYWxfZnJlcV9iYXNlKGluMSwgJnI5LCAmcjEwKTsKKwkJYnJlYWs7CisJY2FzZSBTQUxf
UENJX0NPTkZJR19SRUFEOgorCQlwcmludGsoS0VSTl9XQVJOSU5HImt2bTogTm90IGFsbG93ZWQg
dG8gY2FsbCBoZXJlISIKKwkJCSIgU0FMX1BDSV9DT05GSUdfUkVBRFxuIik7CisJCWJyZWFrOwor
CWNhc2UgU0FMX1BDSV9DT05GSUdfV1JJVEU6CisJCXByaW50ayhLRVJOX1dBUk5JTkcia3ZtOiBO
b3QgYWxsb3dlZCB0byBjYWxsIGhlcmUhIgorCQkJIiBTQUxfUENJX0NPTkZJR19XUklURVxuIik7
CisJCWJyZWFrOworCWNhc2UgU0FMX1NFVF9WRUNUT1JTOgorCQlpZiAoaW4xID09IFNBTF9WRUNU
T1JfT1NfQk9PVF9SRU5ERVopIHsKKwkJCWlmIChpbjQgIT0gMCB8fCBpbjUgIT0gMCB8fCBpbjYg
IT0gMCB8fCBpbjcgIT0gMCkgeworCQkJCXN0YXR1cyA9IC0yOworCQkJfSBlbHNlIHsKKwkJCQlr
dm0tPmFyY2gucmR2X3NhbF9kYXRhLmJvb3RfaXAgPSBpbjI7CisJCQkJa3ZtLT5hcmNoLnJkdl9z
YWxfZGF0YS5ib290X2dwID0gaW4zOworCQkJfQorCQkJcHJpbnRrKCJSZW5kdm91cyBjYWxsZWQh
IGlpcDolbHhcblxuIiwgaW4yKTsKKwkJfSBlbHNlCisJCQlwcmludGsoS0VSTl9XQVJOSU5HImt2
bTogQ0FMTEVEIFNBTF9TRVRfVkVDVE9SUyAlbHUuIgorCQkJCQkJCSJpZ25vcmVkLi4uXG4iLCBp
bjEpOworCQlicmVhazsKKwljYXNlIFNBTF9HRVRfU1RBVEVfSU5GTzoKKwkJLyogTm8gbW9yZSBp
bmZvLiAgKi8KKwkJc3RhdHVzID0gLTU7CisJCXI5ID0gMDsKKwkJYnJlYWs7CisJY2FzZSBTQUxf
R0VUX1NUQVRFX0lORk9fU0laRToKKwkJLyogUmV0dXJuIGEgZHVtbXkgc2l6ZS4gICovCisJCXN0
YXR1cyA9IDA7CisJCXI5ID0gMTI4OworCQlicmVhazsKKwljYXNlIFNBTF9DTEVBUl9TVEFURV9J
TkZPOgorCQkvKiBOb29wLiAgKi8KKwkJYnJlYWs7CisJY2FzZSBTQUxfTUNfUkVOREVaOgorCQlw
cmludGsoS0VSTl9XQVJOSU5HCisJCQkia3ZtOiBjYWxsZWQgU0FMX01DX1JFTkRFWi4gaWdub3Jl
ZC4uLlxuIik7CisJCWJyZWFrOworCWNhc2UgU0FMX01DX1NFVF9QQVJBTVM6CisJCXByaW50ayhL
RVJOX1dBUk5JTkcKKwkJCSJrdm06IGNhbGxlZCAgU0FMX01DX1NFVF9QQVJBTVMuaWdub3JlZCFc
biIpOworCQlicmVhazsKKwljYXNlIFNBTF9DQUNIRV9GTFVTSDoKKwkJaWYgKDEpIHsKKwkJCS8q
Rmx1c2ggdXNpbmcgU0FMLgorCQkJVGhpcyBtZXRob2QgaXMgZmFzdGVyIGJ1dCBoYXMgYSBzaWRl
CisJCQllZmZlY3Qgb24gb3RoZXIgdmNwdSBydW5uaW5nIG9uCisJCQl0aGlzIGNwdS4gICovCisJ
CQlzdGF0dXMgPSBpYTY0X3NhbF9jYWNoZV9mbHVzaChpbjEpOworCQl9IGVsc2UgeworCQkJLypN
YXliZSBuZWVkIHRvIGltcGxlbWVudCB0aGUgbWV0aG9kCisJCQl3aXRob3V0IHNpZGUgZWZmZWN0
ISovCisJCQlzdGF0dXMgPSAwOworCQl9CisJCWJyZWFrOworCWNhc2UgU0FMX0NBQ0hFX0lOSVQ6
CisJCXByaW50ayhLRVJOX1dBUk5JTkcKKwkJCSJrdm06IGNhbGxlZCBTQUxfQ0FDSEVfSU5JVC4g
IGlnbm9yZWQuLi5cbiIpOworCQlicmVhazsKKwljYXNlIFNBTF9VUERBVEVfUEFMOgorCQlwcmlu
dGsoS0VSTl9XQVJOSU5HCisJCQkia3ZtOiBDQUxMRUQgU0FMX1VQREFURV9QQUwuICBpZ25vcmVk
Li4uXG4iKTsKKwkJYnJlYWs7CisJZGVmYXVsdDoKKwkJcHJpbnRrKEtFUk5fV0FSTklORyJrdm06
IGNhbGxlZCBTQUxfQ0FMTCB3aXRoIHVua25vd24gaW5kZXguIgorCQkJCQkJIiBpbmRleDolbGRc
biIsIGluZGV4KTsKKwkJc3RhdHVzID0gLTE7CisJCWJyZWFrOworCX0KKwlyZXR1cm4gKChzdHJ1
Y3Qgc2FsX3JldF92YWx1ZXMpIHtzdGF0dXMsIHI5LCByMTAsIHIxMX0pOworfQorCitzdGF0aWMg
dm9pZCBrdm1fZ2V0X3NhbF9jYWxsX2RhdGEoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCB1NjQgKmlu
MCwgdTY0ICppbjEsCisJCXU2NCAqaW4yLCB1NjQgKmluMywgdTY0ICppbjQsIHU2NCAqaW41LCB1
NjQgKmluNiwgdTY0ICppbjcpeworCisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnA7CisKKwlwID0g
a3ZtX2dldF9leGl0X2RhdGEodmNwdSk7CisKKwlpZiAocCkgeworCQlpZiAocC0+ZXhpdF9yZWFz
b24gPT0gRVhJVF9SRUFTT05fU0FMX0NBTEwpIHsKKwkJCSppbjAgPSBwLT51LnNhbF9kYXRhLmlu
MDsKKwkJCSppbjEgPSBwLT51LnNhbF9kYXRhLmluMTsKKwkJCSppbjIgPSBwLT51LnNhbF9kYXRh
LmluMjsKKwkJCSppbjMgPSBwLT51LnNhbF9kYXRhLmluMzsKKwkJCSppbjQgPSBwLT51LnNhbF9k
YXRhLmluNDsKKwkJCSppbjUgPSBwLT51LnNhbF9kYXRhLmluNTsKKwkJCSppbjYgPSBwLT51LnNh
bF9kYXRhLmluNjsKKwkJCSppbjcgPSBwLT51LnNhbF9kYXRhLmluNzsKKwkJCXJldHVybiA7CisJ
CX0KKwl9CisJKmluMCA9IDA7Cit9CisKK3ZvaWQga3ZtX3NhbF9lbXVsKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSkKK3sKKworCXN0cnVjdCBzYWxfcmV0X3ZhbHVlcyByZXN1bHQ7CisJdTY0IGluZGV4
LCBpbjEsIGluMiwgaW4zLCBpbjQsIGluNSwgaW42LCBpbjc7CisKKwlrdm1fZ2V0X3NhbF9jYWxs
X2RhdGEodmNwdSwgJmluZGV4LCAmaW4xLCAmaW4yLAorCQkJJmluMywgJmluNCwgJmluNSwgJmlu
NiwgJmluNyk7CisJcmVzdWx0ID0gc2FsX2VtdWxhdG9yKHZjcHUtPmt2bSwgaW5kZXgsIGluMSwg
aW4yLCBpbjMsCisJCQkJCWluNCwgaW41LCBpbjYsIGluNyk7CisJc2V0X3NhbF9yZXN1bHQodmNw
dSwgcmVzdWx0KTsKK30KLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C863F4.21BC202F--
