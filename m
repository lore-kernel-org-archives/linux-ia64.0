From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:48:28 +0000
Subject: [10/18][PATCH] KVM:IA64 : Add mmio decoder for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048729@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E5.EB77F2EB"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E5.EB77F2EB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 6fcd534964e91d409ee4dba39c393dc7cf019b97 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:53:32 +0800
Subject: [PATCH] KVM:IA64 : Add mmio decoder for kvm/ia64.

mmio.c includes mmio decoder, and related mmio logics..
Signed-off-by: Anthony Xu <Anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/mmio.c |  341
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 341 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/mmio.c

diff --git a/arch/ia64/kvm/mmio.c b/arch/ia64/kvm/mmio.c
new file mode 100644
index 0000000..351bf70
--- /dev/null
+++ b/arch/ia64/kvm/mmio.c
@@ -0,0 +1,341 @@
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
+static void vlsapic_write_xtp(struct kvm_vcpu *v, uint8_t val)
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
+static void vlsapic_write_ipi(struct kvm_vcpu *vcpu,
+					uint64_t addr, uint64_t data)
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
+void lsapic_write(struct kvm_vcpu *v, unsigned long addr,
+			unsigned long length, unsigned long val)
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
+unsigned long lsapic_read(struct kvm_vcpu *v, unsigned long addr,
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
+static void mmio_access(struct kvm_vcpu *vcpu, u64 src_pa, u64 *dest,
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
+void emulate_io_inst(struct kvm_vcpu *vcpu, u64 padr, u64 ma)
+{
+	struct kvm_pt_regs *regs;
+	IA64_BUNDLE bundle;
+	int slot, dir =3D 0;
+	int inst_type =3D -1;
+	u16 size =3D 0;
+	u64 data, slot1a, slot1b, temp, update_reg;
+	s32 imm;
+	INST64 inst;
+
+	regs =3D vcpu_regs(vcpu);
+
+	if (fetch_code(vcpu, regs->cr_iip, &bundle)) {
+		/* if fetch code fail, return and try again */
+		return;
+	}
+	slot =3D ((struct ia64_psr *)&(regs->cr_ipsr))->ri;
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
+		update_reg =3D vcpu_get_gr(vcpu, inst.M2.r2);
+		temp +=3D update_reg;
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
+			imm =3D (inst.M5.s << 31) | (inst.M5.i << 30) |
+				(inst.M5.imm7 << 23);
+			temp +=3D imm >> 23;
+			vcpu_set_gr(vcpu, inst.M5.r3, temp, 0);
+
+		} else if ((inst.M3.x6 >> 2) < 0xb) {
+			/*read*/
+			dir =3D IOREQ_READ;
+			temp =3D vcpu_get_gr(vcpu, inst.M3.r3);
+			imm =3D (inst.M3.s << 31) | (inst.M3.i << 30) |
+				(inst.M3.imm7 << 23);
+			temp +=3D imm >> 23;
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
+		imm =3D (inst.M10.s << 31) | (inst.M10.i << 30) |
+			(inst.M10.imm7 << 23);
+		temp +=3D imm >> 23;
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
+		imm =3D (inst.M10.s << 31) | (inst.M10.i << 30) |
+			(inst.M10.imm7 << 23);
+		temp +=3D imm >> 23;
+		vcpu_set_gr(vcpu, inst.M10.r3, temp, 0);
+	} else if (inst.M15.major =3D=3D 7 && inst.M15.x6 >=3D 0x2c
+			&& inst.M15.x6 <=3D 0x2f) {
+		temp =3D vcpu_get_gr(vcpu, inst.M15.r3);
+		imm =3D (inst.M15.s << 31) | (inst.M15.i << 30) |
+			(inst.M15.imm7 << 23);
+		temp +=3D imm >> 23;
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
+		if (inst_type =3D=3D SL_INTEGER)
+			vcpu_set_gr(vcpu, inst.M1.r1, data, 0);
+		else
+			panic_vm(vcpu);
+
+	}
+	vcpu_increment_iip(vcpu);
+}
--=20
1.5.2

------_=_NextPart_001_01C893E5.EB77F2EB
Content-Type: application/octet-stream;
	name="0010-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0010-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0010-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch"

RnJvbSA2ZmNkNTM0OTY0ZTkxZDQwOWVlNGRiYTM5YzM5M2RjN2NmMDE5Yjk3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjUzOjMyICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQgOiBBZGQgbW1pbyBkZWNvZGVyIGZvciBrdm0vaWE2NC4KCm1taW8uYyBpbmNsdWRl
cyBtbWlvIGRlY29kZXIsIGFuZCByZWxhdGVkIG1taW8gbG9naWNzLi4KU2lnbmVkLW9mZi1ieTog
QW50aG9ueSBYdSA8QW50aG9ueS54dUBpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8g
WmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0vbW1pby5j
IHwgIDM0MSArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KwogMSBmaWxlcyBjaGFuZ2VkLCAzNDEgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKIGNy
ZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL2lhNjQva3ZtL21taW8uYwoKZGlmZiAtLWdpdCBhL2FyY2gv
aWE2NC9rdm0vbW1pby5jIGIvYXJjaC9pYTY0L2t2bS9tbWlvLmMKbmV3IGZpbGUgbW9kZSAxMDA2
NDQKaW5kZXggMDAwMDAwMC4uMzUxYmY3MAotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2NC9r
dm0vbW1pby5jCkBAIC0wLDAgKzEsMzQxIEBACisvKgorICogbW1pby5jOiBNTUlPIGVtdWxhdGlv
biBjb21wb25lbnRzLgorICogQ29weXJpZ2h0IChjKSAyMDA0LCBJbnRlbCBDb3Jwb3JhdGlvbi4K
KyAqICBZYW96dSBEb25nIChFZGRpZSBEb25nKSAoRWRkaWUuZG9uZ0BpbnRlbC5jb20pCisgKiAg
S3VuIFRpYW4gKEtldmluIFRpYW4pIChLZXZpbi50aWFuQGludGVsLmNvbSkKKyAqCisgKiBDb3B5
cmlnaHQgKGMpIDIwMDcgSW50ZWwgQ29ycG9yYXRpb24gIEtWTSBzdXBwb3J0LgorICogWHVlZmVp
IFh1IChBbnRob255IFh1KSAoYW50aG9ueS54dUBpbnRlbC5jb20pCisgKiBYaWFudGFvIFpoYW5n
ICAoeGlhbnRhby56aGFuZ0BpbnRlbC5jb20pCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGZyZWUg
c29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkgaXQKKyAqIHVu
ZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExp
Y2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBG
b3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUgaG9w
ZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAqIEFOWSBXQVJSQU5UWTsgd2l0aG91
dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcgorICogRklU
TkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFsIFB1Ymxp
YyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoKKyAqIFlvdSBzaG91bGQgaGF2ZSBy
ZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFsb25nIHdp
dGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0d2FyZSBG
b3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBCb3N0b24s
IE1BIDAyMTExLTEzMDcgVVNBLgorICoKKyAqLworCisjaW5jbHVkZSA8bGludXgva3ZtX2hvc3Qu
aD4KKworI2luY2x1ZGUgInZjcHUuaCIKKworc3RhdGljIHZvaWQgdmxzYXBpY193cml0ZV94dHAo
c3RydWN0IGt2bV92Y3B1ICp2LCB1aW50OF90IHZhbCkKK3sKKwlWTFNBUElDX1hUUCh2KSA9IHZh
bDsKK30KKworLyoKKyAqIExTQVBJQyBPRkZTRVQKKyAqLworI2RlZmluZSBQSUJfTE9XX0hBTEYo
b2ZzdCkgICAgICEob2ZzdCAmICgxIDw8IDIwKSkKKyNkZWZpbmUgUElCX09GU1RfSU5UQSAgICAg
ICAgICAweDFFMDAwMAorI2RlZmluZSBQSUJfT0ZTVF9YVFAgICAgICAgICAgIDB4MUUwMDA4CisK
Ky8qCisgKiBleGVjdXRlIHdyaXRlIElQSSBvcC4KKyAqLworc3RhdGljIHZvaWQgdmxzYXBpY193
cml0ZV9pcGkoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LAorCQkJCQl1aW50NjRfdCBhZGRyLCB1aW50
NjRfdCBkYXRhKQoreworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJmN1cnJlbnRfdmNwdS0+
YXJjaC5leGl0X2RhdGE7CisJdW5zaWduZWQgbG9uZyBwc3I7CisKKwlsb2NhbF9pcnFfc2F2ZShw
c3IpOworCisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9JUEk7CisJcC0+dS5pcGlfZGF0
YS5hZGRyLnZhbCA9IGFkZHI7CisJcC0+dS5pcGlfZGF0YS5kYXRhLnZhbCA9IGRhdGE7CisJdm1t
X3RyYW5zaXRpb24oY3VycmVudF92Y3B1KTsKKworCWxvY2FsX2lycV9yZXN0b3JlKHBzcik7CisK
K30KKwordm9pZCBsc2FwaWNfd3JpdGUoc3RydWN0IGt2bV92Y3B1ICp2LCB1bnNpZ25lZCBsb25n
IGFkZHIsCisJCQl1bnNpZ25lZCBsb25nIGxlbmd0aCwgdW5zaWduZWQgbG9uZyB2YWwpCit7CisJ
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
IGxvbmcgbHNhcGljX3JlYWQoc3RydWN0IGt2bV92Y3B1ICp2LCB1bnNpZ25lZCBsb25nIGFkZHIs
CisJCXVuc2lnbmVkIGxvbmcgbGVuZ3RoKQoreworCXVpbnQ2NF90IHJlc3VsdCA9IDA7CisKKwlh
ZGRyICY9IChQSUJfU0laRSAtIDEpOworCisJc3dpdGNoIChhZGRyKSB7CisJY2FzZSBQSUJfT0ZT
VF9JTlRBOgorCQlpZiAobGVuZ3RoID09IDEpIC8qIDEgYnl0ZSBsb2FkICovCisJCQk7IC8qIFRo
ZXJlIGlzIG5vIGk4MjU5LCB0aGVyZSBpcyBubyBJTlRBIGFjY2VzcyovCisJCWVsc2UKKwkJCS8q
cGFuaWNfZG9tYWluKE5VTEwsIlVuZGVmaW5lZCByZWFkIG9uIFBJQiBJTlRBXG4iKTsgKi8KKwkJ
CXBhbmljX3ZtKHYpOworCisJCWJyZWFrOworCWNhc2UgUElCX09GU1RfWFRQOgorCQlpZiAobGVu
Z3RoID09IDEpIHsKKwkJCXJlc3VsdCA9IFZMU0FQSUNfWFRQKHYpOworCQkJLyogcHJpbnRrKCJy
ZWFkIHh0cCAlbHhcbiIsIHJlc3VsdCk7ICovCisJCX0gZWxzZSB7CisJCQkvKnBhbmljX2RvbWFp
bihOVUxMLAorCQkJIlVuZGVmaW5lZCByZWFkIG9uIFBJQiBYVFBcbiIpOyovCisJCQlwYW5pY192
bSh2KTsKKwkJfQorCQlicmVhazsKKwlkZWZhdWx0OgorCQlwYW5pY192bSh2KTsKKwkJYnJlYWs7
CisJfQorCXJldHVybiByZXN1bHQ7Cit9CisKK3N0YXRpYyB2b2lkIG1taW9fYWNjZXNzKHN0cnVj
dCBrdm1fdmNwdSAqdmNwdSwgdTY0IHNyY19wYSwgdTY0ICpkZXN0LAorCQkJCQl1MTYgcywgaW50
IG1hLCBpbnQgZGlyKQoreworCXVuc2lnbmVkIGxvbmcgaW90OworCXN0cnVjdCBleGl0X2N0bF9k
YXRhICpwID0gJnZjcHUtPmFyY2guZXhpdF9kYXRhOworCXVuc2lnbmVkIGxvbmcgcHNyOworCisJ
aW90ID0gX19ncGZuX2lzX2lvKHNyY19wYSA+PiBQQUdFX1NISUZUKTsKKworCWxvY2FsX2lycV9z
YXZlKHBzcik7CisKKwkvKkludGVyY2VwdCB0aGUgYWNjZXMgZm9yIFBJQiByYW5nZSovCisJaWYg
KGlvdCA9PSBHUEZOX1BJQikgeworCQlpZiAoIWRpcikKKwkJCWxzYXBpY193cml0ZSh2Y3B1LCBz
cmNfcGEsIHMsICpkZXN0KTsKKwkJZWxzZQorCQkJKmRlc3QgPSBsc2FwaWNfcmVhZCh2Y3B1LCBz
cmNfcGEsIHMpOworCQlnb3RvIG91dDsKKwl9CisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNP
Tl9NTUlPX0lOU1RSVUNUSU9OOworCXAtPnUuaW9yZXEuYWRkciA9IHNyY19wYTsKKwlwLT51Lmlv
cmVxLnNpemUgPSBzOworCXAtPnUuaW9yZXEuZGlyID0gZGlyOworCWlmIChkaXIgPT0gSU9SRVFf
V1JJVEUpCisJCXAtPnUuaW9yZXEuZGF0YSA9ICpkZXN0OworCXAtPnUuaW9yZXEuc3RhdGUgPSBT
VEFURV9JT1JFUV9SRUFEWTsKKwl2bW1fdHJhbnNpdGlvbih2Y3B1KTsKKworCWlmIChwLT51Lmlv
cmVxLnN0YXRlID09IFNUQVRFX0lPUkVTUF9SRUFEWSkgeworCQlpZiAoZGlyID09IElPUkVRX1JF
QUQpCisJCQkqZGVzdCA9IHAtPnUuaW9yZXEuZGF0YTsKKwl9IGVsc2UKKwkJcGFuaWNfdm0odmNw
dSk7CitvdXQ6CisJbG9jYWxfaXJxX3Jlc3RvcmUocHNyKTsKKwlyZXR1cm4gOworfQorCisvKgor
ICAgZGlyIDE6IHJlYWQgMDp3cml0ZQorICAgaW5zdF90eXBlIDA6aW50ZWdlciAxOmZsb2F0aW5n
IHBvaW50CisgKi8KKyNkZWZpbmUgU0xfSU5URUdFUgkwCS8qIHN0b3JlL2xvYWQgaW50ZXJnZXIq
LworI2RlZmluZSBTTF9GTE9BVElORwkxICAgICAJLyogc3RvcmUvbG9hZCBmbG9hdGluZyovCisK
K3ZvaWQgZW11bGF0ZV9pb19pbnN0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0IHBhZHIsIHU2
NCBtYSkKK3sKKwlzdHJ1Y3Qga3ZtX3B0X3JlZ3MgKnJlZ3M7CisJSUE2NF9CVU5ETEUgYnVuZGxl
OworCWludCBzbG90LCBkaXIgPSAwOworCWludCBpbnN0X3R5cGUgPSAtMTsKKwl1MTYgc2l6ZSA9
IDA7CisJdTY0IGRhdGEsIHNsb3QxYSwgc2xvdDFiLCB0ZW1wLCB1cGRhdGVfcmVnOworCXMzMiBp
bW07CisJSU5TVDY0IGluc3Q7CisKKwlyZWdzID0gdmNwdV9yZWdzKHZjcHUpOworCisJaWYgKGZl
dGNoX2NvZGUodmNwdSwgcmVncy0+Y3JfaWlwLCAmYnVuZGxlKSkgeworCQkvKiBpZiBmZXRjaCBj
b2RlIGZhaWwsIHJldHVybiBhbmQgdHJ5IGFnYWluICovCisJCXJldHVybjsKKwl9CisJc2xvdCA9
ICgoc3RydWN0IGlhNjRfcHNyICopJihyZWdzLT5jcl9pcHNyKSktPnJpOworCWlmICghc2xvdCkK
KwkJaW5zdC5pbnN0ID0gYnVuZGxlLnNsb3QwOworCWVsc2UgaWYgKHNsb3QgPT0gMSkgeworCQlz
bG90MWEgPSBidW5kbGUuc2xvdDFhOworCQlzbG90MWIgPSBidW5kbGUuc2xvdDFiOworCQlpbnN0
Lmluc3QgPSBzbG90MWEgKyAoc2xvdDFiIDw8IDE4KTsKKwl9IGVsc2UgaWYgKHNsb3QgPT0gMikK
KwkJaW5zdC5pbnN0ID0gYnVuZGxlLnNsb3QyOworCisJLyogSW50ZWdlciBMb2FkL1N0b3JlICov
CisJaWYgKGluc3QuTTEubWFqb3IgPT0gNCAmJiBpbnN0Lk0xLm0gPT0gMCAmJiBpbnN0Lk0xLngg
PT0gMCkgeworCQlpbnN0X3R5cGUgPSBTTF9JTlRFR0VSOworCQlzaXplID0gKGluc3QuTTEueDYg
JiAweDMpOworCQlpZiAoKGluc3QuTTEueDYgPj4gMikgPiAweGIpIHsKKwkJCS8qd3JpdGUqLwor
CQkJZGlyID0gSU9SRVFfV1JJVEU7CisJCQlkYXRhID0gdmNwdV9nZXRfZ3IodmNwdSwgaW5zdC5N
NC5yMik7CisJCX0gZWxzZSBpZiAoKGluc3QuTTEueDYgPj4gMikgPCAweGIpIHsKKwkJCS8qcmVh
ZCovCisJCQlkaXIgPSBJT1JFUV9SRUFEOworCQl9CisJfSBlbHNlIGlmIChpbnN0Lk0yLm1ham9y
ID09IDQgJiYgaW5zdC5NMi5tID09IDEgJiYgaW5zdC5NMi54ID09IDApIHsKKwkJLyogSW50ZWdl
ciBMb2FkICsgUmVnIHVwZGF0ZSAqLworCQlpbnN0X3R5cGUgPSBTTF9JTlRFR0VSOworCQlkaXIg
PSBJT1JFUV9SRUFEOworCQlzaXplID0gKGluc3QuTTIueDYgJiAweDMpOworCQl0ZW1wID0gdmNw
dV9nZXRfZ3IodmNwdSwgaW5zdC5NMi5yMyk7CisJCXVwZGF0ZV9yZWcgPSB2Y3B1X2dldF9ncih2
Y3B1LCBpbnN0Lk0yLnIyKTsKKwkJdGVtcCArPSB1cGRhdGVfcmVnOworCQl2Y3B1X3NldF9ncih2
Y3B1LCBpbnN0Lk0yLnIzLCB0ZW1wLCAwKTsKKwl9IGVsc2UgaWYgKGluc3QuTTMubWFqb3IgPT0g
NSkgeworCQkvKkludGVnZXIgTG9hZC9TdG9yZSArIEltbSB1cGRhdGUqLworCQlpbnN0X3R5cGUg
PSBTTF9JTlRFR0VSOworCQlzaXplID0gKGluc3QuTTMueDYmMHgzKTsKKwkJaWYgKChpbnN0Lk01
Lng2ID4+IDIpID4gMHhiKSB7CisJCQkvKndyaXRlKi8KKwkJCWRpciA9IElPUkVRX1dSSVRFOwor
CQkJZGF0YSA9IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTUucjIpOworCQkJdGVtcCA9IHZjcHVf
Z2V0X2dyKHZjcHUsIGluc3QuTTUucjMpOworCQkJaW1tID0gKGluc3QuTTUucyA8PCAzMSkgfCAo
aW5zdC5NNS5pIDw8IDMwKSB8CisJCQkJKGluc3QuTTUuaW1tNyA8PCAyMyk7CisJCQl0ZW1wICs9
IGltbSA+PiAyMzsKKwkJCXZjcHVfc2V0X2dyKHZjcHUsIGluc3QuTTUucjMsIHRlbXAsIDApOwor
CisJCX0gZWxzZSBpZiAoKGluc3QuTTMueDYgPj4gMikgPCAweGIpIHsKKwkJCS8qcmVhZCovCisJ
CQlkaXIgPSBJT1JFUV9SRUFEOworCQkJdGVtcCA9IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTMu
cjMpOworCQkJaW1tID0gKGluc3QuTTMucyA8PCAzMSkgfCAoaW5zdC5NMy5pIDw8IDMwKSB8CisJ
CQkJKGluc3QuTTMuaW1tNyA8PCAyMyk7CisJCQl0ZW1wICs9IGltbSA+PiAyMzsKKwkJCXZjcHVf
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
KTsKKwkJdGVtcCA9IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTEwLnIzKTsKKwkJaW1tID0gKGlu
c3QuTTEwLnMgPDwgMzEpIHwgKGluc3QuTTEwLmkgPDwgMzApIHwKKwkJCShpbnN0Lk0xMC5pbW03
IDw8IDIzKTsKKwkJdGVtcCArPSBpbW0gPj4gMjM7CisJCXZjcHVfc2V0X2dyKHZjcHUsIGluc3Qu
TTEwLnIzLCB0ZW1wLCAwKTsKKworCQkvKiBXcml0ZSBoaWdoIHdvcmQuRklYTUU6IHRoaXMgaXMg
YSBrbHVkZ2UhICAqLworCQl2LnUuYml0c1sxXSAmPSAweDNmZmZmOworCQltbWlvX2FjY2Vzcyh2
Y3B1LCBwYWRyICsgOCwgJnYudS5iaXRzWzFdLCA4LCBtYSwgSU9SRVFfV1JJVEUpOworCQlkYXRh
ID0gdi51LmJpdHNbMF07CisJCXNpemUgPSAzOworCX0gZWxzZSBpZiAoaW5zdC5NMTAubWFqb3Ig
PT0gNyAmJiBpbnN0Lk0xMC54NiA9PSAweDMxKSB7CisJCS8qIEZsb2F0aW5nLXBvaW50IHN0Zjgg
KyBJbW0gdXBkYXRlICovCisJCXN0cnVjdCBpYTY0X2ZwcmVnIHY7CisJCWluc3RfdHlwZSA9IFNM
X0ZMT0FUSU5HOworCQlkaXIgPSBJT1JFUV9XUklURTsKKwkJc2l6ZSA9IDM7CisJCXZjcHVfZ2V0
X2ZwcmVnKHZjcHUsIGluc3QuTTEwLmYyLCAmdik7CisJCWRhdGEgPSB2LnUuYml0c1swXTsgLyog
U2lnbmlmaWNhbmQuICAqLworCQl0ZW1wID0gdmNwdV9nZXRfZ3IodmNwdSwgaW5zdC5NMTAucjMp
OworCQlpbW0gPSAoaW5zdC5NMTAucyA8PCAzMSkgfCAoaW5zdC5NMTAuaSA8PCAzMCkgfAorCQkJ
KGluc3QuTTEwLmltbTcgPDwgMjMpOworCQl0ZW1wICs9IGltbSA+PiAyMzsKKwkJdmNwdV9zZXRf
Z3IodmNwdSwgaW5zdC5NMTAucjMsIHRlbXAsIDApOworCX0gZWxzZSBpZiAoaW5zdC5NMTUubWFq
b3IgPT0gNyAmJiBpbnN0Lk0xNS54NiA+PSAweDJjCisJCQkmJiBpbnN0Lk0xNS54NiA8PSAweDJm
KSB7CisJCXRlbXAgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk0xNS5yMyk7CisJCWltbSA9IChp
bnN0Lk0xNS5zIDw8IDMxKSB8IChpbnN0Lk0xNS5pIDw8IDMwKSB8CisJCQkoaW5zdC5NMTUuaW1t
NyA8PCAyMyk7CisJCXRlbXAgKz0gaW1tID4+IDIzOworCQl2Y3B1X3NldF9ncih2Y3B1LCBpbnN0
Lk0xNS5yMywgdGVtcCwgMCk7CisKKwkJdmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOworCQlyZXR1
cm47CisJfSBlbHNlIGlmIChpbnN0Lk0xMi5tYWpvciA9PSA2ICYmIGluc3QuTTEyLm0gPT0gMQor
CQkJJiYgaW5zdC5NMTIueCA9PSAxICYmIGluc3QuTTEyLng2ID09IDEpIHsKKwkJLyogRmxvYXRp
bmctcG9pbnQgTG9hZCBQYWlyICsgSW1tIGxkZnA4IE0xMiovCisJCXN0cnVjdCBpYTY0X2ZwcmVn
IHY7CisKKwkJaW5zdF90eXBlID0gU0xfRkxPQVRJTkc7CisJCWRpciA9IElPUkVRX1JFQUQ7CisJ
CXNpemUgPSA4OyAgICAgLypsZGZkKi8KKwkJbW1pb19hY2Nlc3ModmNwdSwgcGFkciwgJmRhdGEs
IHNpemUsIG1hLCBkaXIpOworCQl2LnUuYml0c1swXSA9IGRhdGE7CisJCXYudS5iaXRzWzFdID0g
MHgxMDAzRTsKKwkJdmNwdV9zZXRfZnByZWcodmNwdSwgaW5zdC5NMTIuZjEsICZ2KTsKKwkJcGFk
ciArPSA4OworCQltbWlvX2FjY2Vzcyh2Y3B1LCBwYWRyLCAmZGF0YSwgc2l6ZSwgbWEsIGRpcik7
CisJCXYudS5iaXRzWzBdID0gZGF0YTsKKwkJdi51LmJpdHNbMV0gPSAweDEwMDNFOworCQl2Y3B1
X3NldF9mcHJlZyh2Y3B1LCBpbnN0Lk0xMi5mMiwgJnYpOworCQlwYWRyICs9IDg7CisJCXZjcHVf
c2V0X2dyKHZjcHUsIGluc3QuTTEyLnIzLCBwYWRyLCAwKTsKKwkJdmNwdV9pbmNyZW1lbnRfaWlw
KHZjcHUpOworCQlyZXR1cm47CisJfSBlbHNlIHsKKwkJaW5zdF90eXBlID0gLTE7CisJCXBhbmlj
X3ZtKHZjcHUpOworCX0KKworCXNpemUgPSAxIDw8IHNpemU7CisJaWYgKGRpciA9PSBJT1JFUV9X
UklURSkgeworCQltbWlvX2FjY2Vzcyh2Y3B1LCBwYWRyLCAmZGF0YSwgc2l6ZSwgbWEsIGRpcik7
CisJfSBlbHNlIHsKKwkJbW1pb19hY2Nlc3ModmNwdSwgcGFkciwgJmRhdGEsIHNpemUsIG1hLCBk
aXIpOworCQlpZiAoaW5zdF90eXBlID09IFNMX0lOVEVHRVIpCisJCQl2Y3B1X3NldF9ncih2Y3B1
LCBpbnN0Lk0xLnIxLCBkYXRhLCAwKTsKKwkJZWxzZQorCQkJcGFuaWNfdm0odmNwdSk7CisKKwl9
CisJdmNwdV9pbmNyZW1lbnRfaWlwKHZjcHUpOworfQotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E5.EB77F2EB--
