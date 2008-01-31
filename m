From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:47 +0000
Subject: [PATCH] [11]Add mmio decoder for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FCE@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.34746687"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.34746687
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 15:45:48 +0800
Subject: [PATCH] kvm/ia64: Add mmio decoder for kvm/ia64.

mmio.c includes mmio decoder routines.
Signed-off-by: Anthony Xu <Anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/mmio.c |  349
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 349 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/mmio.c

diff --git a/arch/ia64/kvm/mmio.c b/arch/ia64/kvm/mmio.c
new file mode 100644
index 0000000..3f8027a
--- /dev/null
+++ b/arch/ia64/kvm/mmio.c
@@ -0,0 +1,349 @@
+/*
+ * mmio.c: MMIO emulation components.
+ * Copyright (c) 2004, Intel Corporation.
+ *  Yaozu Dong (Eddie Dong) (Eddie.dong@intel.com)
+ *  Kun Tian (Kevin Tian) (Kevin.tian@intel.com)
+ *
+ * Copyright (c) 2007 Intel Corporation  KVM support.
+ * Xuefei Xu (Anthony Xu) (anthony.xu@intel.com)
+ * Xiantao Zhang  (xiantao.zhang@intel.com)
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
+ *
+ */
+
+#include <linux/kvm_host.h>
+
+#include "vcpu.h"
+
+static void vlsapic_write_xtp(VCPU *v, uint8_t val)
+{
+	VLSAPIC_XTP(v) =3D val;
+}
+
+/*
+ * LSAPIC OFFSET
+ */
+#define PIB_LOW_HALF(ofst)     !(ofst & (1 << 20))
+#define PIB_OFST_INTA          0x1E0000
+#define PIB_OFST_XTP           0x1E0008
+
+/*
+ * execute write IPI op.
+ */
+static void vlsapic_write_ipi(VCPU *vcpu, uint64_t addr, uint64_t data)
+{
+	struct exit_ctl_data *p =3D &current_vcpu->arch.exit_data;
+	unsigned long psr;
+
+	local_irq_save(psr);
+
+	p->exit_reason =3D EXIT_REASON_IPI;
+	p->u.ipi_data.addr.val =3D addr;
+	p->u.ipi_data.data.val =3D data;
+	vmm_transition(current_vcpu);
+
+	local_irq_restore(psr);
+
+}
+
+void lsapic_write(VCPU *v, unsigned long addr, unsigned long length,
+		unsigned long val)
+{
+	addr &=3D (PIB_SIZE - 1);
+
+	switch (addr) {
+	case PIB_OFST_INTA:
+		/*panic_domain(NULL, "Undefined write on PIB INTA\n");*/
+		panic_vm(v);
+		break;
+	case PIB_OFST_XTP:
+		if (length =3D=3D 1) {
+			vlsapic_write_xtp(v, val);
+		} else {
+			/*panic_domain(NULL,
+			"Undefined write on PIB XTP\n");*/
+			panic_vm(v);
+		}
+		break;
+	default:
+		if (PIB_LOW_HALF(addr)) {
+			/*lower half */
+			if (length !=3D 8)
+				/*panic_domain(NULL,
+				"Can't LHF write with size %ld!\n",
+				length);*/
+				panic_vm(v);
+			else
+				vlsapic_write_ipi(v, addr, val);
+		} else {   /*	upper half
+				printk("IPI-UHF write %lx\n",addr);*/
+			panic_vm(v);
+		}
+		break;
+	}
+}
+
+unsigned long lsapic_read(VCPU *v, unsigned long addr,
+		unsigned long length)
+{
+	uint64_t result =3D 0;
+
+	addr &=3D (PIB_SIZE - 1);
+
+	switch (addr) {
+	case PIB_OFST_INTA:
+		if (length =3D=3D 1) /* 1 byte load */
+			; /* There is no i8259, there is no INTA
access*/
+		else
+			/*panic_domain(NULL,"Undefined read on PIB
INTA\n"); */
+			panic_vm(v);
+
+		break;
+	case PIB_OFST_XTP:
+		if (length =3D=3D 1) {
+			result =3D VLSAPIC_XTP(v);
+			/* printk("read xtp %lx\n", result); */
+		} else {
+			/*panic_domain(NULL,
+			"Undefined read on PIB XTP\n");*/
+			panic_vm(v);
+		}
+		break;
+	default:
+		panic_vm(v);
+		break;
+	}
+	return result;
+}
+
+static void mmio_access(VCPU *vcpu, u64 src_pa, u64 *dest,
+					u16 s, int ma, int dir)
+{
+	unsigned long iot;
+	struct exit_ctl_data *p =3D &vcpu->arch.exit_data;
+	unsigned long psr;
+
+	iot =3D __gpfn_is_io(src_pa >> PAGE_SHIFT);
+
+	local_irq_save(psr);
+
+	/*Intercept the acces for PIB range*/
+	if (iot =3D=3D GPFN_PIB) {
+		if (!dir)
+			lsapic_write(vcpu, src_pa, s, *dest);
+		else
+			*dest =3D lsapic_read(vcpu, src_pa, s);
+		goto out;
+	}
+	p->exit_reason =3D EXIT_REASON_MMIO_INSTRUCTION;
+	p->u.ioreq.addr =3D src_pa;
+	p->u.ioreq.size =3D s;
+	p->u.ioreq.dir =3D dir;
+	if (dir =3D=3D IOREQ_WRITE)
+		p->u.ioreq.data =3D *dest;
+	p->u.ioreq.state =3D STATE_IOREQ_READY;
+	vmm_transition(vcpu);
+
+	if (p->u.ioreq.state =3D=3D STATE_IORESP_READY) {
+		if (dir =3D=3D IOREQ_READ)
+			*dest =3D p->u.ioreq.data;
+	} else
+		panic_vm(vcpu);
+out:
+	local_irq_restore(psr);
+	return ;
+}
+
+/*
+   dir 1: read 0:write
+   inst_type 0:integer 1:floating point
+ */
+#define SL_INTEGER	0	/* store/load interger*/
+#define SL_FLOATING	1     	/* store/load floating*/
+
+void emulate_io_inst(VCPU *vcpu, u64 padr, u64 ma)
+{
+	REGS *regs;
+	IA64_BUNDLE bundle;
+	int slot, dir =3D 0;
+	int inst_type =3D -1;
+	u16 size =3D 0;
+	u64 data, post_update, slot1a, slot1b, temp;
+	INST64 inst;
+
+	regs =3D vcpu_regs(vcpu);
+
+	if (fetch_code(vcpu, regs->cr_iip, &bundle)) {
+		/* if fetch code fail, return and try again */
+		return;
+	}
+	slot =3D ((ia64_psr *)&(regs->cr_ipsr))->ri;
+	if (!slot)
+		inst.inst =3D bundle.slot0;
+	else if (slot =3D=3D 1) {
+		slot1a =3D bundle.slot1a;
+		slot1b =3D bundle.slot1b;
+		inst.inst =3D slot1a + (slot1b << 18);
+	} else if (slot =3D=3D 2)
+		inst.inst =3D bundle.slot2;
+
+	/* Integer Load/Store */
+	if (inst.M1.major =3D=3D 4 && inst.M1.m =3D=3D 0 && inst.M1.x =3D=3D =
0) {
+		inst_type =3D SL_INTEGER;
+		size =3D (inst.M1.x6 & 0x3);
+		if ((inst.M1.x6 >> 2) > 0xb) {
+			/*write*/
+			dir =3D IOREQ_WRITE;
+			data =3D vcpu_get_gr(vcpu, inst.M4.r2);
+		} else if ((inst.M1.x6 >> 2) < 0xb) {
+			/*read*/
+			dir =3D IOREQ_READ;
+		}
+	} else if (inst.M2.major =3D=3D 4 && inst.M2.m =3D=3D 1 && inst.M2.x =
=3D=3D
0) {
+		/* Integer Load + Reg update */
+		inst_type =3D SL_INTEGER;
+		dir =3D IOREQ_READ;
+		size =3D (inst.M2.x6 & 0x3);
+		temp =3D vcpu_get_gr(vcpu, inst.M2.r3);
+		post_update =3D vcpu_get_gr(vcpu, inst.M2.r2);
+		temp +=3D post_update;
+		vcpu_set_gr(vcpu, inst.M2.r3, temp, 0);
+	} else if (inst.M3.major =3D=3D 5) {
+		/*Integer Load/Store + Imm update*/
+		inst_type =3D SL_INTEGER;
+		size =3D (inst.M3.x6&0x3);
+		if ((inst.M5.x6 >> 2) > 0xb) {
+			/*write*/
+			dir =3D IOREQ_WRITE;
+			data =3D vcpu_get_gr(vcpu, inst.M5.r2);
+			temp =3D vcpu_get_gr(vcpu, inst.M5.r3);
+			post_update =3D (inst.M5.i << 7) + inst.M5.imm7;
+			if (inst.M5.s)
+				temp -=3D post_update;
+			else
+				temp +=3D post_update;
+			vcpu_set_gr(vcpu, inst.M5.r3, temp, 0);
+
+		} else if ((inst.M3.x6 >> 2) < 0xb) {
+			/*read*/
+			dir =3D IOREQ_READ;
+			temp =3D vcpu_get_gr(vcpu, inst.M3.r3);
+			post_update =3D (inst.M3.i << 7) + inst.M3.imm7;
+			if (inst.M3.s)
+				temp -=3D post_update;
+			else
+				temp +=3D post_update;
+			vcpu_set_gr(vcpu, inst.M3.r3, temp, 0);
+
+		}
+	} else if (inst.M9.major =3D=3D 6 && inst.M9.x6 =3D=3D 0x3B
+				&& inst.M9.m =3D=3D 0 && inst.M9.x =3D=3D 0) {
+		/* Floating-point spill*/
+		struct ia64_fpreg v;
+
+		inst_type =3D SL_FLOATING;
+		dir =3D IOREQ_WRITE;
+		vcpu_get_fpreg(vcpu, inst.M9.f2, &v);
+		/* Write high word. FIXME: this is a kludge!  */
+		v.u.bits[1] &=3D 0x3ffff;
+		mmio_access(vcpu, padr + 8, &v.u.bits[1], 8, ma,
IOREQ_WRITE);
+		data =3D v.u.bits[0];
+		size =3D 3;
+	} else if (inst.M10.major =3D=3D 7 && inst.M10.x6 =3D=3D 0x3B) {
+		/* Floating-point spill + Imm update */
+		struct ia64_fpreg v;
+
+		inst_type =3D SL_FLOATING;
+		dir =3D IOREQ_WRITE;
+		vcpu_get_fpreg(vcpu, inst.M10.f2, &v);
+		temp =3D vcpu_get_gr(vcpu, inst.M10.r3);
+		post_update =3D (inst.M10.i << 7) + inst.M10.imm7;
+		if (inst.M10.s)
+			temp -=3D post_update;
+		else
+			temp +=3D post_update;
+		vcpu_set_gr(vcpu, inst.M10.r3, temp, 0);
+
+		/* Write high word.FIXME: this is a kludge!  */
+		v.u.bits[1] &=3D 0x3ffff;
+		mmio_access(vcpu, padr + 8, &v.u.bits[1], 8, ma,
IOREQ_WRITE);
+		data =3D v.u.bits[0];
+		size =3D 3;
+	} else if (inst.M10.major =3D=3D 7 && inst.M10.x6 =3D=3D 0x31) {
+		/* Floating-point stf8 + Imm update */
+		struct ia64_fpreg v;
+		inst_type =3D SL_FLOATING;
+		dir =3D IOREQ_WRITE;
+		size =3D 3;
+		vcpu_get_fpreg(vcpu, inst.M10.f2, &v);
+		data =3D v.u.bits[0]; /* Significand.  */
+		temp =3D vcpu_get_gr(vcpu, inst.M10.r3);
+		post_update =3D (inst.M10.i << 7) + inst.M10.imm7;
+		if (inst.M10.s)
+			temp -=3D post_update;
+		else
+			temp +=3D post_update;
+		vcpu_set_gr(vcpu, inst.M10.r3, temp, 0);
+	} else if (inst.M15.major =3D=3D 7 && inst.M15.x6 >=3D 0x2c
+			&& inst.M15.x6 <=3D 0x2f) {
+		temp =3D vcpu_get_gr(vcpu, inst.M15.r3);
+		post_update =3D (inst.M15.i << 7) + inst.M15.imm7;
+		if (inst.M15.s)
+			temp -=3D post_update;
+		else
+			temp +=3D post_update;
+		vcpu_set_gr(vcpu, inst.M15.r3, temp, 0);
+
+		vcpu_increment_iip(vcpu);
+		return;
+	} else if (inst.M12.major =3D=3D 6 && inst.M12.m =3D=3D 1
+			&& inst.M12.x =3D=3D 1 && inst.M12.x6 =3D=3D 1) {
+		/* Floating-point Load Pair + Imm ldfp8 M12*/
+		struct ia64_fpreg v;
+
+		inst_type =3D SL_FLOATING;
+		dir =3D IOREQ_READ;
+		size =3D 8;     /*ldfd*/
+		mmio_access(vcpu, padr, &data, size, ma, dir);
+		v.u.bits[0] =3D data;
+		v.u.bits[1] =3D 0x1003E;
+		vcpu_set_fpreg(vcpu, inst.M12.f1, &v);
+		padr +=3D 8;
+		mmio_access(vcpu, padr, &data, size, ma, dir);
+		v.u.bits[0] =3D data;
+		v.u.bits[1] =3D 0x1003E;
+		vcpu_set_fpreg(vcpu, inst.M12.f2, &v);
+		padr +=3D 8;
+		vcpu_set_gr(vcpu, inst.M12.r3, padr, 0);
+		vcpu_increment_iip(vcpu);
+		return;
+	} else {
+		inst_type =3D -1;
+		panic_vm(vcpu);
+	}
+
+	size =3D 1 << size;
+	if (dir =3D=3D IOREQ_WRITE) {
+		mmio_access(vcpu, padr, &data, size, ma, dir);
+	} else {
+		mmio_access(vcpu, padr, &data, size, ma, dir);
+		if (inst_type =3D=3D SL_INTEGER) {
+			vcpu_set_gr(vcpu, inst.M1.r1, data, 0);
+		} else {
+			panic_vm(vcpu);
+		}
+	}
+	vcpu_increment_iip(vcpu);
+}
--=20
1.5.1

------_=_NextPart_001_01C863F4.34746687
Content-Type: application/octet-stream;
	name="0011-kvm-ia64-Add-mmio-decoder-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0011-kvm-ia64-Add-mmio-decoder-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0011-kvm-ia64-Add-mmio-decoder-for-kvm-ia64.patch"

RnJvbSBjMzY2MjYwNzI2MDA4NmQ3YjFmYTFlZGEwYjQxMjBiOGM3ODI3ZTY4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxNTo0NTo0OCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgbW1pbyBkZWNvZGVyIGZvciBrdm0vaWE2NC4KCm1taW8uYyBpbmNsdWRl
cyBtbWlvIGRlY29kZXIgcm91dGluZXMuClNpZ25lZC1vZmYtYnk6IEFudGhvbnkgWHUgPEFudGhv
bnkueHVAaW50ZWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpo
YW5nQGludGVsLmNvbT4KLS0tCiBhcmNoL2lhNjQva3ZtL21taW8uYyB8ICAzNDkgKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIDEgZmlsZXMgY2hhbmdl
ZCwgMzQ5IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQg
YXJjaC9pYTY0L2t2bS9tbWlvLmMKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL21taW8uYyBi
L2FyY2gvaWE2NC9rdm0vbW1pby5jCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAu
LjNmODAyN2EKLS0tIC9kZXYvbnVsbAorKysgYi9hcmNoL2lhNjQva3ZtL21taW8uYwpAQCAtMCww
ICsxLDM0OSBAQAorLyoKKyAqIG1taW8uYzogTU1JTyBlbXVsYXRpb24gY29tcG9uZW50cy4KKyAq
IENvcHlyaWdodCAoYykgMjAwNCwgSW50ZWwgQ29ycG9yYXRpb24uCisgKiAgWWFvenUgRG9uZyAo
RWRkaWUgRG9uZykgKEVkZGllLmRvbmdAaW50ZWwuY29tKQorICogIEt1biBUaWFuIChLZXZpbiBU
aWFuKSAoS2V2aW4udGlhbkBpbnRlbC5jb20pCisgKgorICogQ29weXJpZ2h0IChjKSAyMDA3IElu
dGVsIENvcnBvcmF0aW9uICBLVk0gc3VwcG9ydC4KKyAqIFh1ZWZlaSBYdSAoQW50aG9ueSBYdSkg
KGFudGhvbnkueHVAaW50ZWwuY29tKQorICogWGlhbnRhbyBaaGFuZyAgKHhpYW50YW8uemhhbmdA
aW50ZWwuY29tKQorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2Fu
IHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5k
IGNvbmRpdGlvbnMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lv
biAyLCBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisg
KiBUaGlzIHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2Vm
dWwsIGJ1dCBXSVRIT1VUCisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGll
ZCB3YXJyYW50eSBvZiBNRVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElD
VUxBUiBQVVJQT1NFLiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAq
IG1vcmUgZGV0YWlscy4KKyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9m
IHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dy
YW07IGlmIG5vdCwgd3JpdGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwg
NTkgVGVtcGxlCisgKiBQbGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVT
QS4KKyAqCisgKi8KKworI2luY2x1ZGUgPGxpbnV4L2t2bV9ob3N0Lmg+CisKKyNpbmNsdWRlICJ2
Y3B1LmgiCisKK3N0YXRpYyB2b2lkIHZsc2FwaWNfd3JpdGVfeHRwKFZDUFUgKnYsIHVpbnQ4X3Qg
dmFsKQoreworCVZMU0FQSUNfWFRQKHYpID0gdmFsOworfQorCisvKgorICogTFNBUElDIE9GRlNF
VAorICovCisjZGVmaW5lIFBJQl9MT1dfSEFMRihvZnN0KSAgICAgIShvZnN0ICYgKDEgPDwgMjAp
KQorI2RlZmluZSBQSUJfT0ZTVF9JTlRBICAgICAgICAgIDB4MUUwMDAwCisjZGVmaW5lIFBJQl9P
RlNUX1hUUCAgICAgICAgICAgMHgxRTAwMDgKKworLyoKKyAqIGV4ZWN1dGUgd3JpdGUgSVBJIG9w
LgorICovCitzdGF0aWMgdm9pZCB2bHNhcGljX3dyaXRlX2lwaShWQ1BVICp2Y3B1LCB1aW50NjRf
dCBhZGRyLCB1aW50NjRfdCBkYXRhKQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJmN1
cnJlbnRfdmNwdS0+YXJjaC5leGl0X2RhdGE7CisJdW5zaWduZWQgbG9uZyBwc3I7CisKKwlsb2Nh
bF9pcnFfc2F2ZShwc3IpOworCisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9JUEk7CisJ
cC0+dS5pcGlfZGF0YS5hZGRyLnZhbCA9IGFkZHI7CisJcC0+dS5pcGlfZGF0YS5kYXRhLnZhbCA9
IGRhdGE7CisJdm1tX3RyYW5zaXRpb24oY3VycmVudF92Y3B1KTsKKworCWxvY2FsX2lycV9yZXN0
b3JlKHBzcik7CisKK30KKwordm9pZCBsc2FwaWNfd3JpdGUoVkNQVSAqdiwgdW5zaWduZWQgbG9u
ZyBhZGRyLCB1bnNpZ25lZCBsb25nIGxlbmd0aCwKKwkJdW5zaWduZWQgbG9uZyB2YWwpCit7CisJ
YWRkciAmPSAoUElCX1NJWkUgLSAxKTsKKworCXN3aXRjaCAoYWRkcikgeworCWNhc2UgUElCX09G
U1RfSU5UQToKKwkJLypwYW5pY19kb21haW4oTlVMTCwgIlVuZGVmaW5lZCB3cml0ZSBvbiBQSUIg
SU5UQVxuIik7Ki8KKwkJcGFuaWNfdm0odik7CisJCWJyZWFrOworCWNhc2UgUElCX09GU1RfWFRQ
OgorCQlpZiAobGVuZ3RoID09IDEpIHsKKwkJCXZsc2FwaWNfd3JpdGVfeHRwKHYsIHZhbCk7CisJ
CX0gZWxzZSB7CisJCQkvKnBhbmljX2RvbWFpbihOVUxMLAorCQkJIlVuZGVmaW5lZCB3cml0ZSBv
biBQSUIgWFRQXG4iKTsqLworCQkJcGFuaWNfdm0odik7CisJCX0KKwkJYnJlYWs7CisJZGVmYXVs
dDoKKwkJaWYgKFBJQl9MT1dfSEFMRihhZGRyKSkgeworCQkJLypsb3dlciBoYWxmICovCisJCQlp
ZiAobGVuZ3RoICE9IDgpCisJCQkJLypwYW5pY19kb21haW4oTlVMTCwKKwkJCQkiQ2FuJ3QgTEhG
IHdyaXRlIHdpdGggc2l6ZSAlbGQhXG4iLAorCQkJCWxlbmd0aCk7Ki8KKwkJCQlwYW5pY192bSh2
KTsKKwkJCWVsc2UKKwkJCQl2bHNhcGljX3dyaXRlX2lwaSh2LCBhZGRyLCB2YWwpOworCQl9IGVs
c2UgeyAgIC8qCXVwcGVyIGhhbGYKKwkJCQlwcmludGsoIklQSS1VSEYgd3JpdGUgJWx4XG4iLGFk
ZHIpOyovCisJCQlwYW5pY192bSh2KTsKKwkJfQorCQlicmVhazsKKwl9Cit9CisKK3Vuc2lnbmVk
IGxvbmcgbHNhcGljX3JlYWQoVkNQVSAqdiwgdW5zaWduZWQgbG9uZyBhZGRyLAorCQl1bnNpZ25l
ZCBsb25nIGxlbmd0aCkKK3sKKwl1aW50NjRfdCByZXN1bHQgPSAwOworCisJYWRkciAmPSAoUElC
X1NJWkUgLSAxKTsKKworCXN3aXRjaCAoYWRkcikgeworCWNhc2UgUElCX09GU1RfSU5UQToKKwkJ
aWYgKGxlbmd0aCA9PSAxKSAvKiAxIGJ5dGUgbG9hZCAqLworCQkJOyAvKiBUaGVyZSBpcyBubyBp
ODI1OSwgdGhlcmUgaXMgbm8gSU5UQSBhY2Nlc3MqLworCQllbHNlCisJCQkvKnBhbmljX2RvbWFp
bihOVUxMLCJVbmRlZmluZWQgcmVhZCBvbiBQSUIgSU5UQVxuIik7ICovCisJCQlwYW5pY192bSh2
KTsKKworCQlicmVhazsKKwljYXNlIFBJQl9PRlNUX1hUUDoKKwkJaWYgKGxlbmd0aCA9PSAxKSB7
CisJCQlyZXN1bHQgPSBWTFNBUElDX1hUUCh2KTsKKwkJCS8qIHByaW50aygicmVhZCB4dHAgJWx4
XG4iLCByZXN1bHQpOyAqLworCQl9IGVsc2UgeworCQkJLypwYW5pY19kb21haW4oTlVMTCwKKwkJ
CSJVbmRlZmluZWQgcmVhZCBvbiBQSUIgWFRQXG4iKTsqLworCQkJcGFuaWNfdm0odik7CisJCX0K
KwkJYnJlYWs7CisJZGVmYXVsdDoKKwkJcGFuaWNfdm0odik7CisJCWJyZWFrOworCX0KKwlyZXR1
cm4gcmVzdWx0OworfQorCitzdGF0aWMgdm9pZCBtbWlvX2FjY2VzcyhWQ1BVICp2Y3B1LCB1NjQg
c3JjX3BhLCB1NjQgKmRlc3QsCisJCQkJCXUxNiBzLCBpbnQgbWEsIGludCBkaXIpCit7CisJdW5z
aWduZWQgbG9uZyBpb3Q7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEgKnAgPSAmdmNwdS0+YXJjaC5l
eGl0X2RhdGE7CisJdW5zaWduZWQgbG9uZyBwc3I7CisKKwlpb3QgPSBfX2dwZm5faXNfaW8oc3Jj
X3BhID4+IFBBR0VfU0hJRlQpOworCisJbG9jYWxfaXJxX3NhdmUocHNyKTsKKworCS8qSW50ZXJj
ZXB0IHRoZSBhY2NlcyBmb3IgUElCIHJhbmdlKi8KKwlpZiAoaW90ID09IEdQRk5fUElCKSB7CisJ
CWlmICghZGlyKQorCQkJbHNhcGljX3dyaXRlKHZjcHUsIHNyY19wYSwgcywgKmRlc3QpOworCQll
bHNlCisJCQkqZGVzdCA9IGxzYXBpY19yZWFkKHZjcHUsIHNyY19wYSwgcyk7CisJCWdvdG8gb3V0
OworCX0KKwlwLT5leGl0X3JlYXNvbiA9IEVYSVRfUkVBU09OX01NSU9fSU5TVFJVQ1RJT047CisJ
cC0+dS5pb3JlcS5hZGRyID0gc3JjX3BhOworCXAtPnUuaW9yZXEuc2l6ZSA9IHM7CisJcC0+dS5p
b3JlcS5kaXIgPSBkaXI7CisJaWYgKGRpciA9PSBJT1JFUV9XUklURSkKKwkJcC0+dS5pb3JlcS5k
YXRhID0gKmRlc3Q7CisJcC0+dS5pb3JlcS5zdGF0ZSA9IFNUQVRFX0lPUkVRX1JFQURZOworCXZt
bV90cmFuc2l0aW9uKHZjcHUpOworCisJaWYgKHAtPnUuaW9yZXEuc3RhdGUgPT0gU1RBVEVfSU9S
RVNQX1JFQURZKSB7CisJCWlmIChkaXIgPT0gSU9SRVFfUkVBRCkKKwkJCSpkZXN0ID0gcC0+dS5p
b3JlcS5kYXRhOworCX0gZWxzZQorCQlwYW5pY192bSh2Y3B1KTsKK291dDoKKwlsb2NhbF9pcnFf
cmVzdG9yZShwc3IpOworCXJldHVybiA7Cit9CisKKy8qCisgICBkaXIgMTogcmVhZCAwOndyaXRl
CisgICBpbnN0X3R5cGUgMDppbnRlZ2VyIDE6ZmxvYXRpbmcgcG9pbnQKKyAqLworI2RlZmluZSBT
TF9JTlRFR0VSCTAJLyogc3RvcmUvbG9hZCBpbnRlcmdlciovCisjZGVmaW5lIFNMX0ZMT0FUSU5H
CTEgICAgIAkvKiBzdG9yZS9sb2FkIGZsb2F0aW5nKi8KKwordm9pZCBlbXVsYXRlX2lvX2luc3Qo
VkNQVSAqdmNwdSwgdTY0IHBhZHIsIHU2NCBtYSkKK3sKKwlSRUdTICpyZWdzOworCUlBNjRfQlVO
RExFIGJ1bmRsZTsKKwlpbnQgc2xvdCwgZGlyID0gMDsKKwlpbnQgaW5zdF90eXBlID0gLTE7CisJ
dTE2IHNpemUgPSAwOworCXU2NCBkYXRhLCBwb3N0X3VwZGF0ZSwgc2xvdDFhLCBzbG90MWIsIHRl
bXA7CisJSU5TVDY0IGluc3Q7CisKKwlyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCisJaWYgKGZl
dGNoX2NvZGUodmNwdSwgcmVncy0+Y3JfaWlwLCAmYnVuZGxlKSkgeworCQkvKiBpZiBmZXRjaCBj
b2RlIGZhaWwsIHJldHVybiBhbmQgdHJ5IGFnYWluICovCisJCXJldHVybjsKKwl9CisJc2xvdCA9
ICgoaWE2NF9wc3IgKikmKHJlZ3MtPmNyX2lwc3IpKS0+cmk7CisJaWYgKCFzbG90KQorCQlpbnN0
Lmluc3QgPSBidW5kbGUuc2xvdDA7CisJZWxzZSBpZiAoc2xvdCA9PSAxKSB7CisJCXNsb3QxYSA9
IGJ1bmRsZS5zbG90MWE7CisJCXNsb3QxYiA9IGJ1bmRsZS5zbG90MWI7CisJCWluc3QuaW5zdCA9
IHNsb3QxYSArIChzbG90MWIgPDwgMTgpOworCX0gZWxzZSBpZiAoc2xvdCA9PSAyKQorCQlpbnN0
Lmluc3QgPSBidW5kbGUuc2xvdDI7CisKKwkvKiBJbnRlZ2VyIExvYWQvU3RvcmUgKi8KKwlpZiAo
aW5zdC5NMS5tYWpvciA9PSA0ICYmIGluc3QuTTEubSA9PSAwICYmIGluc3QuTTEueCA9PSAwKSB7
CisJCWluc3RfdHlwZSA9IFNMX0lOVEVHRVI7CisJCXNpemUgPSAoaW5zdC5NMS54NiAmIDB4Myk7
CisJCWlmICgoaW5zdC5NMS54NiA+PiAyKSA+IDB4YikgeworCQkJLyp3cml0ZSovCisJCQlkaXIg
PSBJT1JFUV9XUklURTsKKwkJCWRhdGEgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk00LnIyKTsK
KwkJfSBlbHNlIGlmICgoaW5zdC5NMS54NiA+PiAyKSA8IDB4YikgeworCQkJLypyZWFkKi8KKwkJ
CWRpciA9IElPUkVRX1JFQUQ7CisJCX0KKwl9IGVsc2UgaWYgKGluc3QuTTIubWFqb3IgPT0gNCAm
JiBpbnN0Lk0yLm0gPT0gMSAmJiBpbnN0Lk0yLnggPT0gMCkgeworCQkvKiBJbnRlZ2VyIExvYWQg
KyBSZWcgdXBkYXRlICovCisJCWluc3RfdHlwZSA9IFNMX0lOVEVHRVI7CisJCWRpciA9IElPUkVR
X1JFQUQ7CisJCXNpemUgPSAoaW5zdC5NMi54NiAmIDB4Myk7CisJCXRlbXAgPSB2Y3B1X2dldF9n
cih2Y3B1LCBpbnN0Lk0yLnIzKTsKKwkJcG9zdF91cGRhdGUgPSB2Y3B1X2dldF9ncih2Y3B1LCBp
bnN0Lk0yLnIyKTsKKwkJdGVtcCArPSBwb3N0X3VwZGF0ZTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwg
aW5zdC5NMi5yMywgdGVtcCwgMCk7CisJfSBlbHNlIGlmIChpbnN0Lk0zLm1ham9yID09IDUpIHsK
KwkJLypJbnRlZ2VyIExvYWQvU3RvcmUgKyBJbW0gdXBkYXRlKi8KKwkJaW5zdF90eXBlID0gU0xf
SU5URUdFUjsKKwkJc2l6ZSA9IChpbnN0Lk0zLng2JjB4Myk7CisJCWlmICgoaW5zdC5NNS54NiA+
PiAyKSA+IDB4YikgeworCQkJLyp3cml0ZSovCisJCQlkaXIgPSBJT1JFUV9XUklURTsKKwkJCWRh
dGEgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk01LnIyKTsKKwkJCXRlbXAgPSB2Y3B1X2dldF9n
cih2Y3B1LCBpbnN0Lk01LnIzKTsKKwkJCXBvc3RfdXBkYXRlID0gKGluc3QuTTUuaSA8PCA3KSAr
IGluc3QuTTUuaW1tNzsKKwkJCWlmIChpbnN0Lk01LnMpCisJCQkJdGVtcCAtPSBwb3N0X3VwZGF0
ZTsKKwkJCWVsc2UKKwkJCQl0ZW1wICs9IHBvc3RfdXBkYXRlOworCQkJdmNwdV9zZXRfZ3IodmNw
dSwgaW5zdC5NNS5yMywgdGVtcCwgMCk7CisKKwkJfSBlbHNlIGlmICgoaW5zdC5NMy54NiA+PiAy
KSA8IDB4YikgeworCQkJLypyZWFkKi8KKwkJCWRpciA9IElPUkVRX1JFQUQ7CisJCQl0ZW1wID0g
dmNwdV9nZXRfZ3IodmNwdSwgaW5zdC5NMy5yMyk7CisJCQlwb3N0X3VwZGF0ZSA9IChpbnN0Lk0z
LmkgPDwgNykgKyBpbnN0Lk0zLmltbTc7CisJCQlpZiAoaW5zdC5NMy5zKQorCQkJCXRlbXAgLT0g
cG9zdF91cGRhdGU7CisJCQllbHNlCisJCQkJdGVtcCArPSBwb3N0X3VwZGF0ZTsKKwkJCXZjcHVf
c2V0X2dyKHZjcHUsIGluc3QuTTMucjMsIHRlbXAsIDApOworCisJCX0KKwl9IGVsc2UgaWYgKGlu
c3QuTTkubWFqb3IgPT0gNiAmJiBpbnN0Lk05Lng2ID09IDB4M0IKKwkJCQkmJiBpbnN0Lk05Lm0g
PT0gMCAmJiBpbnN0Lk05LnggPT0gMCkgeworCQkvKiBGbG9hdGluZy1wb2ludCBzcGlsbCovCisJ
CXN0cnVjdCBpYTY0X2ZwcmVnIHY7CisKKwkJaW5zdF90eXBlID0gU0xfRkxPQVRJTkc7CisJCWRp
ciA9IElPUkVRX1dSSVRFOworCQl2Y3B1X2dldF9mcHJlZyh2Y3B1LCBpbnN0Lk05LmYyLCAmdik7
CisJCS8qIFdyaXRlIGhpZ2ggd29yZC4gRklYTUU6IHRoaXMgaXMgYSBrbHVkZ2UhICAqLworCQl2
LnUuYml0c1sxXSAmPSAweDNmZmZmOworCQltbWlvX2FjY2Vzcyh2Y3B1LCBwYWRyICsgOCwgJnYu
dS5iaXRzWzFdLCA4LCBtYSwgSU9SRVFfV1JJVEUpOworCQlkYXRhID0gdi51LmJpdHNbMF07CisJ
CXNpemUgPSAzOworCX0gZWxzZSBpZiAoaW5zdC5NMTAubWFqb3IgPT0gNyAmJiBpbnN0Lk0xMC54
NiA9PSAweDNCKSB7CisJCS8qIEZsb2F0aW5nLXBvaW50IHNwaWxsICsgSW1tIHVwZGF0ZSAqLwor
CQlzdHJ1Y3QgaWE2NF9mcHJlZyB2OworCisJCWluc3RfdHlwZSA9IFNMX0ZMT0FUSU5HOworCQlk
aXIgPSBJT1JFUV9XUklURTsKKwkJdmNwdV9nZXRfZnByZWcodmNwdSwgaW5zdC5NMTAuZjIsICZ2
KTsKKwkJdGVtcCA9IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTEwLnIzKTsKKwkJcG9zdF91cGRh
dGUgPSAoaW5zdC5NMTAuaSA8PCA3KSArIGluc3QuTTEwLmltbTc7CisJCWlmIChpbnN0Lk0xMC5z
KQorCQkJdGVtcCAtPSBwb3N0X3VwZGF0ZTsKKwkJZWxzZQorCQkJdGVtcCArPSBwb3N0X3VwZGF0
ZTsKKwkJdmNwdV9zZXRfZ3IodmNwdSwgaW5zdC5NMTAucjMsIHRlbXAsIDApOworCisJCS8qIFdy
aXRlIGhpZ2ggd29yZC5GSVhNRTogdGhpcyBpcyBhIGtsdWRnZSEgICovCisJCXYudS5iaXRzWzFd
ICY9IDB4M2ZmZmY7CisJCW1taW9fYWNjZXNzKHZjcHUsIHBhZHIgKyA4LCAmdi51LmJpdHNbMV0s
IDgsIG1hLCBJT1JFUV9XUklURSk7CisJCWRhdGEgPSB2LnUuYml0c1swXTsKKwkJc2l6ZSA9IDM7
CisJfSBlbHNlIGlmIChpbnN0Lk0xMC5tYWpvciA9PSA3ICYmIGluc3QuTTEwLng2ID09IDB4MzEp
IHsKKwkJLyogRmxvYXRpbmctcG9pbnQgc3RmOCArIEltbSB1cGRhdGUgKi8KKwkJc3RydWN0IGlh
NjRfZnByZWcgdjsKKwkJaW5zdF90eXBlID0gU0xfRkxPQVRJTkc7CisJCWRpciA9IElPUkVRX1dS
SVRFOworCQlzaXplID0gMzsKKwkJdmNwdV9nZXRfZnByZWcodmNwdSwgaW5zdC5NMTAuZjIsICZ2
KTsKKwkJZGF0YSA9IHYudS5iaXRzWzBdOyAvKiBTaWduaWZpY2FuZC4gICovCisJCXRlbXAgPSB2
Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk0xMC5yMyk7CisJCXBvc3RfdXBkYXRlID0gKGluc3QuTTEw
LmkgPDwgNykgKyBpbnN0Lk0xMC5pbW03OworCQlpZiAoaW5zdC5NMTAucykKKwkJCXRlbXAgLT0g
cG9zdF91cGRhdGU7CisJCWVsc2UKKwkJCXRlbXAgKz0gcG9zdF91cGRhdGU7CisJCXZjcHVfc2V0
X2dyKHZjcHUsIGluc3QuTTEwLnIzLCB0ZW1wLCAwKTsKKwl9IGVsc2UgaWYgKGluc3QuTTE1Lm1h
am9yID09IDcgJiYgaW5zdC5NMTUueDYgPj0gMHgyYworCQkJJiYgaW5zdC5NMTUueDYgPD0gMHgy
ZikgeworCQl0ZW1wID0gdmNwdV9nZXRfZ3IodmNwdSwgaW5zdC5NMTUucjMpOworCQlwb3N0X3Vw
ZGF0ZSA9IChpbnN0Lk0xNS5pIDw8IDcpICsgaW5zdC5NMTUuaW1tNzsKKwkJaWYgKGluc3QuTTE1
LnMpCisJCQl0ZW1wIC09IHBvc3RfdXBkYXRlOworCQllbHNlCisJCQl0ZW1wICs9IHBvc3RfdXBk
YXRlOworCQl2Y3B1X3NldF9ncih2Y3B1LCBpbnN0Lk0xNS5yMywgdGVtcCwgMCk7CisKKwkJdmNw
dV9pbmNyZW1lbnRfaWlwKHZjcHUpOworCQlyZXR1cm47CisJfSBlbHNlIGlmIChpbnN0Lk0xMi5t
YWpvciA9PSA2ICYmIGluc3QuTTEyLm0gPT0gMQorCQkJJiYgaW5zdC5NMTIueCA9PSAxICYmIGlu
c3QuTTEyLng2ID09IDEpIHsKKwkJLyogRmxvYXRpbmctcG9pbnQgTG9hZCBQYWlyICsgSW1tIGxk
ZnA4IE0xMiovCisJCXN0cnVjdCBpYTY0X2ZwcmVnIHY7CisKKwkJaW5zdF90eXBlID0gU0xfRkxP
QVRJTkc7CisJCWRpciA9IElPUkVRX1JFQUQ7CisJCXNpemUgPSA4OyAgICAgLypsZGZkKi8KKwkJ
bW1pb19hY2Nlc3ModmNwdSwgcGFkciwgJmRhdGEsIHNpemUsIG1hLCBkaXIpOworCQl2LnUuYml0
c1swXSA9IGRhdGE7CisJCXYudS5iaXRzWzFdID0gMHgxMDAzRTsKKwkJdmNwdV9zZXRfZnByZWco
dmNwdSwgaW5zdC5NMTIuZjEsICZ2KTsKKwkJcGFkciArPSA4OworCQltbWlvX2FjY2Vzcyh2Y3B1
LCBwYWRyLCAmZGF0YSwgc2l6ZSwgbWEsIGRpcik7CisJCXYudS5iaXRzWzBdID0gZGF0YTsKKwkJ
di51LmJpdHNbMV0gPSAweDEwMDNFOworCQl2Y3B1X3NldF9mcHJlZyh2Y3B1LCBpbnN0Lk0xMi5m
MiwgJnYpOworCQlwYWRyICs9IDg7CisJCXZjcHVfc2V0X2dyKHZjcHUsIGluc3QuTTEyLnIzLCBw
YWRyLCAwKTsKKwkJdmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOworCQlyZXR1cm47CisJfSBlbHNl
IHsKKwkJaW5zdF90eXBlID0gLTE7CisJCXBhbmljX3ZtKHZjcHUpOworCX0KKworCXNpemUgPSAx
IDw8IHNpemU7CisJaWYgKGRpciA9PSBJT1JFUV9XUklURSkgeworCQltbWlvX2FjY2Vzcyh2Y3B1
LCBwYWRyLCAmZGF0YSwgc2l6ZSwgbWEsIGRpcik7CisJfSBlbHNlIHsKKwkJbW1pb19hY2Nlc3Mo
dmNwdSwgcGFkciwgJmRhdGEsIHNpemUsIG1hLCBkaXIpOworCQlpZiAoaW5zdF90eXBlID09IFNM
X0lOVEVHRVIpIHsKKwkJCXZjcHVfc2V0X2dyKHZjcHUsIGluc3QuTTEucjEsIGRhdGEsIDApOwor
CQl9IGVsc2UgeworCQkJcGFuaWNfdm0odmNwdSk7CisJCX0KKwl9CisJdmNwdV9pbmNyZW1lbnRf
aWlwKHZjcHUpOworfQotLSAKMS41LjEKCg==

------_=_NextPart_001_01C863F4.34746687--
