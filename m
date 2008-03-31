From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:28:44 +0000
Subject: [09/17] [PATCH] kvm/ia64: Add mmio decoder for kvm/ia64. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104824D@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.3BECA437"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF7@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF7@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.3BECA437
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From cb572f8887ccfb939457c79fb2d2893ead2a3632 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 10:08:09 +0800
Subject: [PATCH] KVM:IA64 : Add mmio decoder for kvm/ia64.

mmio.c includes mmio decoder routines.
Signed-off-by: Anthony Xu <Anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/mmio.c |  340
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 340 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/mmio.c

diff --git a/arch/ia64/kvm/mmio.c b/arch/ia64/kvm/mmio.c
new file mode 100644
index 0000000..9ba879f
--- /dev/null
+++ b/arch/ia64/kvm/mmio.c
@@ -0,0 +1,340 @@
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
+		if (inst_type =3D=3D SL_INTEGER) {
+			vcpu_set_gr(vcpu, inst.M1.r1, data, 0);
+		} else {
+			panic_vm(vcpu);
+		}
+	}
+	vcpu_increment_iip(vcpu);
+}
--=20
1.5.2

------_=_NextPart_001_01C89309.3BECA437
Content-Type: application/octet-stream;
	name="0009-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0009-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0009-KVM-IA64-Add-mmio-decoder-for-kvm-ia64.patch"

RnJvbSBjYjU3MmY4ODg3Y2NmYjkzOTQ1N2M3OWZiMmQyODkzZWFkMmEzNjMyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogTW9uLCAzMSBNYXIgMjAwOCAxMDowODowOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogQWRkIG1taW8gZGVjb2RlciBmb3Iga3ZtL2lhNjQuCgptbWlvLmMgaW5jbHVk
ZXMgbW1pbyBkZWNvZGVyIHJvdXRpbmVzLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxBbnRo
b255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS9tbWlvLmMgfCAgMzQwICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDM0MCBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vbW1pby5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS9tbWlvLmMg
Yi9hcmNoL2lhNjQva3ZtL21taW8uYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAw
Li45YmE4NzlmCi0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS9tbWlvLmMKQEAgLTAs
MCArMSwzNDAgQEAKKy8qCisgKiBtbWlvLmM6IE1NSU8gZW11bGF0aW9uIGNvbXBvbmVudHMuCisg
KiBDb3B5cmlnaHQgKGMpIDIwMDQsIEludGVsIENvcnBvcmF0aW9uLgorICogIFlhb3p1IERvbmcg
KEVkZGllIERvbmcpIChFZGRpZS5kb25nQGludGVsLmNvbSkKKyAqICBLdW4gVGlhbiAoS2V2aW4g
VGlhbikgKEtldmluLnRpYW5AaW50ZWwuY29tKQorICoKKyAqIENvcHlyaWdodCAoYykgMjAwNyBJ
bnRlbCBDb3Jwb3JhdGlvbiAgS1ZNIHN1cHBvcnQuCisgKiBYdWVmZWkgWHUgKEFudGhvbnkgWHUp
IChhbnRob255Lnh1QGludGVsLmNvbSkKKyAqIFhpYW50YW8gWmhhbmcgICh4aWFudGFvLnpoYW5n
QGludGVsLmNvbSkKKyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNh
biByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFu
ZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNp
b24gMiwgYXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgor
ICogVGhpcyBwcm9ncmFtIGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNl
ZnVsLCBidXQgV0lUSE9VVAorICogQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxp
ZWQgd2FycmFudHkgb2YgTUVSQ0hBTlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJ
Q1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisg
KiBtb3JlIGRldGFpbHMuCisgKgorICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBv
ZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9n
cmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4s
IDU5IFRlbXBsZQorICogUGxhY2UgLSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBV
U0EuCisgKgorICovCisKKyNpbmNsdWRlIDxsaW51eC9rdm1faG9zdC5oPgorCisjaW5jbHVkZSAi
dmNwdS5oIgorCitzdGF0aWMgdm9pZCB2bHNhcGljX3dyaXRlX3h0cChWQ1BVICp2LCB1aW50OF90
IHZhbCkKK3sKKwlWTFNBUElDX1hUUCh2KSA9IHZhbDsKK30KKworLyoKKyAqIExTQVBJQyBPRkZT
RVQKKyAqLworI2RlZmluZSBQSUJfTE9XX0hBTEYob2ZzdCkgICAgICEob2ZzdCAmICgxIDw8IDIw
KSkKKyNkZWZpbmUgUElCX09GU1RfSU5UQSAgICAgICAgICAweDFFMDAwMAorI2RlZmluZSBQSUJf
T0ZTVF9YVFAgICAgICAgICAgIDB4MUUwMDA4CisKKy8qCisgKiBleGVjdXRlIHdyaXRlIElQSSBv
cC4KKyAqLworc3RhdGljIHZvaWQgdmxzYXBpY193cml0ZV9pcGkoVkNQVSAqdmNwdSwgdWludDY0
X3QgYWRkciwgdWludDY0X3QgZGF0YSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9ICZj
dXJyZW50X3ZjcHUtPmFyY2guZXhpdF9kYXRhOworCXVuc2lnbmVkIGxvbmcgcHNyOworCisJbG9j
YWxfaXJxX3NhdmUocHNyKTsKKworCXAtPmV4aXRfcmVhc29uID0gRVhJVF9SRUFTT05fSVBJOwor
CXAtPnUuaXBpX2RhdGEuYWRkci52YWwgPSBhZGRyOworCXAtPnUuaXBpX2RhdGEuZGF0YS52YWwg
PSBkYXRhOworCXZtbV90cmFuc2l0aW9uKGN1cnJlbnRfdmNwdSk7CisKKwlsb2NhbF9pcnFfcmVz
dG9yZShwc3IpOworCit9CisKK3ZvaWQgbHNhcGljX3dyaXRlKFZDUFUgKnYsIHVuc2lnbmVkIGxv
bmcgYWRkciwgdW5zaWduZWQgbG9uZyBsZW5ndGgsCisJCXVuc2lnbmVkIGxvbmcgdmFsKQorewor
CWFkZHIgJj0gKFBJQl9TSVpFIC0gMSk7CisKKwlzd2l0Y2ggKGFkZHIpIHsKKwljYXNlIFBJQl9P
RlNUX0lOVEE6CisJCS8qcGFuaWNfZG9tYWluKE5VTEwsICJVbmRlZmluZWQgd3JpdGUgb24gUElC
IElOVEFcbiIpOyovCisJCXBhbmljX3ZtKHYpOworCQlicmVhazsKKwljYXNlIFBJQl9PRlNUX1hU
UDoKKwkJaWYgKGxlbmd0aCA9PSAxKSB7CisJCQl2bHNhcGljX3dyaXRlX3h0cCh2LCB2YWwpOwor
CQl9IGVsc2UgeworCQkJLypwYW5pY19kb21haW4oTlVMTCwKKwkJCSJVbmRlZmluZWQgd3JpdGUg
b24gUElCIFhUUFxuIik7Ki8KKwkJCXBhbmljX3ZtKHYpOworCQl9CisJCWJyZWFrOworCWRlZmF1
bHQ6CisJCWlmIChQSUJfTE9XX0hBTEYoYWRkcikpIHsKKwkJCS8qbG93ZXIgaGFsZiAqLworCQkJ
aWYgKGxlbmd0aCAhPSA4KQorCQkJCS8qcGFuaWNfZG9tYWluKE5VTEwsCisJCQkJIkNhbid0IExI
RiB3cml0ZSB3aXRoIHNpemUgJWxkIVxuIiwKKwkJCQlsZW5ndGgpOyovCisJCQkJcGFuaWNfdm0o
dik7CisJCQllbHNlCisJCQkJdmxzYXBpY193cml0ZV9pcGkodiwgYWRkciwgdmFsKTsKKwkJfSBl
bHNlIHsgICAvKgl1cHBlciBoYWxmCisJCQkJcHJpbnRrKCJJUEktVUhGIHdyaXRlICVseFxuIixh
ZGRyKTsqLworCQkJcGFuaWNfdm0odik7CisJCX0KKwkJYnJlYWs7CisJfQorfQorCit1bnNpZ25l
ZCBsb25nIGxzYXBpY19yZWFkKFZDUFUgKnYsIHVuc2lnbmVkIGxvbmcgYWRkciwKKwkJdW5zaWdu
ZWQgbG9uZyBsZW5ndGgpCit7CisJdWludDY0X3QgcmVzdWx0ID0gMDsKKworCWFkZHIgJj0gKFBJ
Ql9TSVpFIC0gMSk7CisKKwlzd2l0Y2ggKGFkZHIpIHsKKwljYXNlIFBJQl9PRlNUX0lOVEE6CisJ
CWlmIChsZW5ndGggPT0gMSkgLyogMSBieXRlIGxvYWQgKi8KKwkJCTsgLyogVGhlcmUgaXMgbm8g
aTgyNTksIHRoZXJlIGlzIG5vIElOVEEgYWNjZXNzKi8KKwkJZWxzZQorCQkJLypwYW5pY19kb21h
aW4oTlVMTCwiVW5kZWZpbmVkIHJlYWQgb24gUElCIElOVEFcbiIpOyAqLworCQkJcGFuaWNfdm0o
dik7CisKKwkJYnJlYWs7CisJY2FzZSBQSUJfT0ZTVF9YVFA6CisJCWlmIChsZW5ndGggPT0gMSkg
eworCQkJcmVzdWx0ID0gVkxTQVBJQ19YVFAodik7CisJCQkvKiBwcmludGsoInJlYWQgeHRwICVs
eFxuIiwgcmVzdWx0KTsgKi8KKwkJfSBlbHNlIHsKKwkJCS8qcGFuaWNfZG9tYWluKE5VTEwsCisJ
CQkiVW5kZWZpbmVkIHJlYWQgb24gUElCIFhUUFxuIik7Ki8KKwkJCXBhbmljX3ZtKHYpOworCQl9
CisJCWJyZWFrOworCWRlZmF1bHQ6CisJCXBhbmljX3ZtKHYpOworCQlicmVhazsKKwl9CisJcmV0
dXJuIHJlc3VsdDsKK30KKworc3RhdGljIHZvaWQgbW1pb19hY2Nlc3MoVkNQVSAqdmNwdSwgdTY0
IHNyY19wYSwgdTY0ICpkZXN0LAorCQkJCQl1MTYgcywgaW50IG1hLCBpbnQgZGlyKQoreworCXVu
c2lnbmVkIGxvbmcgaW90OworCXN0cnVjdCBleGl0X2N0bF9kYXRhICpwID0gJnZjcHUtPmFyY2gu
ZXhpdF9kYXRhOworCXVuc2lnbmVkIGxvbmcgcHNyOworCisJaW90ID0gX19ncGZuX2lzX2lvKHNy
Y19wYSA+PiBQQUdFX1NISUZUKTsKKworCWxvY2FsX2lycV9zYXZlKHBzcik7CisKKwkvKkludGVy
Y2VwdCB0aGUgYWNjZXMgZm9yIFBJQiByYW5nZSovCisJaWYgKGlvdCA9PSBHUEZOX1BJQikgewor
CQlpZiAoIWRpcikKKwkJCWxzYXBpY193cml0ZSh2Y3B1LCBzcmNfcGEsIHMsICpkZXN0KTsKKwkJ
ZWxzZQorCQkJKmRlc3QgPSBsc2FwaWNfcmVhZCh2Y3B1LCBzcmNfcGEsIHMpOworCQlnb3RvIG91
dDsKKwl9CisJcC0+ZXhpdF9yZWFzb24gPSBFWElUX1JFQVNPTl9NTUlPX0lOU1RSVUNUSU9OOwor
CXAtPnUuaW9yZXEuYWRkciA9IHNyY19wYTsKKwlwLT51LmlvcmVxLnNpemUgPSBzOworCXAtPnUu
aW9yZXEuZGlyID0gZGlyOworCWlmIChkaXIgPT0gSU9SRVFfV1JJVEUpCisJCXAtPnUuaW9yZXEu
ZGF0YSA9ICpkZXN0OworCXAtPnUuaW9yZXEuc3RhdGUgPSBTVEFURV9JT1JFUV9SRUFEWTsKKwl2
bW1fdHJhbnNpdGlvbih2Y3B1KTsKKworCWlmIChwLT51LmlvcmVxLnN0YXRlID09IFNUQVRFX0lP
UkVTUF9SRUFEWSkgeworCQlpZiAoZGlyID09IElPUkVRX1JFQUQpCisJCQkqZGVzdCA9IHAtPnUu
aW9yZXEuZGF0YTsKKwl9IGVsc2UKKwkJcGFuaWNfdm0odmNwdSk7CitvdXQ6CisJbG9jYWxfaXJx
X3Jlc3RvcmUocHNyKTsKKwlyZXR1cm4gOworfQorCisvKgorICAgZGlyIDE6IHJlYWQgMDp3cml0
ZQorICAgaW5zdF90eXBlIDA6aW50ZWdlciAxOmZsb2F0aW5nIHBvaW50CisgKi8KKyNkZWZpbmUg
U0xfSU5URUdFUgkwCS8qIHN0b3JlL2xvYWQgaW50ZXJnZXIqLworI2RlZmluZSBTTF9GTE9BVElO
RwkxICAgICAJLyogc3RvcmUvbG9hZCBmbG9hdGluZyovCisKK3ZvaWQgZW11bGF0ZV9pb19pbnN0
KFZDUFUgKnZjcHUsIHU2NCBwYWRyLCB1NjQgbWEpCit7CisJUkVHUyAqcmVnczsKKwlJQTY0X0JV
TkRMRSBidW5kbGU7CisJaW50IHNsb3QsIGRpciA9IDA7CisJaW50IGluc3RfdHlwZSA9IC0xOwor
CXUxNiBzaXplID0gMDsKKwl1NjQgZGF0YSwgc2xvdDFhLCBzbG90MWIsIHRlbXAsIHVwZGF0ZV9y
ZWc7CisJczMyIGltbTsKKwlJTlNUNjQgaW5zdDsKKworCXJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7
CisKKwlpZiAoZmV0Y2hfY29kZSh2Y3B1LCByZWdzLT5jcl9paXAsICZidW5kbGUpKSB7CisJCS8q
IGlmIGZldGNoIGNvZGUgZmFpbCwgcmV0dXJuIGFuZCB0cnkgYWdhaW4gKi8KKwkJcmV0dXJuOwor
CX0KKwlzbG90ID0gKChpYTY0X3BzciAqKSYocmVncy0+Y3JfaXBzcikpLT5yaTsKKwlpZiAoIXNs
b3QpCisJCWluc3QuaW5zdCA9IGJ1bmRsZS5zbG90MDsKKwllbHNlIGlmIChzbG90ID09IDEpIHsK
KwkJc2xvdDFhID0gYnVuZGxlLnNsb3QxYTsKKwkJc2xvdDFiID0gYnVuZGxlLnNsb3QxYjsKKwkJ
aW5zdC5pbnN0ID0gc2xvdDFhICsgKHNsb3QxYiA8PCAxOCk7CisJfSBlbHNlIGlmIChzbG90ID09
IDIpCisJCWluc3QuaW5zdCA9IGJ1bmRsZS5zbG90MjsKKworCS8qIEludGVnZXIgTG9hZC9TdG9y
ZSAqLworCWlmIChpbnN0Lk0xLm1ham9yID09IDQgJiYgaW5zdC5NMS5tID09IDAgJiYgaW5zdC5N
MS54ID09IDApIHsKKwkJaW5zdF90eXBlID0gU0xfSU5URUdFUjsKKwkJc2l6ZSA9IChpbnN0Lk0x
Lng2ICYgMHgzKTsKKwkJaWYgKChpbnN0Lk0xLng2ID4+IDIpID4gMHhiKSB7CisJCQkvKndyaXRl
Ki8KKwkJCWRpciA9IElPUkVRX1dSSVRFOworCQkJZGF0YSA9IHZjcHVfZ2V0X2dyKHZjcHUsIGlu
c3QuTTQucjIpOworCQl9IGVsc2UgaWYgKChpbnN0Lk0xLng2ID4+IDIpIDwgMHhiKSB7CisJCQkv
KnJlYWQqLworCQkJZGlyID0gSU9SRVFfUkVBRDsKKwkJfQorCX0gZWxzZSBpZiAoaW5zdC5NMi5t
YWpvciA9PSA0ICYmIGluc3QuTTIubSA9PSAxICYmIGluc3QuTTIueCA9PSAwKSB7CisJCS8qIElu
dGVnZXIgTG9hZCArIFJlZyB1cGRhdGUgKi8KKwkJaW5zdF90eXBlID0gU0xfSU5URUdFUjsKKwkJ
ZGlyID0gSU9SRVFfUkVBRDsKKwkJc2l6ZSA9IChpbnN0Lk0yLng2ICYgMHgzKTsKKwkJdGVtcCA9
IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTIucjMpOworCQl1cGRhdGVfcmVnID0gdmNwdV9nZXRf
Z3IodmNwdSwgaW5zdC5NMi5yMik7CisJCXRlbXAgKz0gdXBkYXRlX3JlZzsKKwkJdmNwdV9zZXRf
Z3IodmNwdSwgaW5zdC5NMi5yMywgdGVtcCwgMCk7CisJfSBlbHNlIGlmIChpbnN0Lk0zLm1ham9y
ID09IDUpIHsKKwkJLypJbnRlZ2VyIExvYWQvU3RvcmUgKyBJbW0gdXBkYXRlKi8KKwkJaW5zdF90
eXBlID0gU0xfSU5URUdFUjsKKwkJc2l6ZSA9IChpbnN0Lk0zLng2JjB4Myk7CisJCWlmICgoaW5z
dC5NNS54NiA+PiAyKSA+IDB4YikgeworCQkJLyp3cml0ZSovCisJCQlkaXIgPSBJT1JFUV9XUklU
RTsKKwkJCWRhdGEgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk01LnIyKTsKKwkJCXRlbXAgPSB2
Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk01LnIzKTsKKwkJCWltbSA9IChpbnN0Lk01LnMgPDwgMzEp
IHwgKGluc3QuTTUuaSA8PCAzMCkgfAorCQkJCShpbnN0Lk01LmltbTcgPDwgMjMpOworCQkJdGVt
cCArPSBpbW0gPj4gMjM7CisJCQl2Y3B1X3NldF9ncih2Y3B1LCBpbnN0Lk01LnIzLCB0ZW1wLCAw
KTsKKworCQl9IGVsc2UgaWYgKChpbnN0Lk0zLng2ID4+IDIpIDwgMHhiKSB7CisJCQkvKnJlYWQq
LworCQkJZGlyID0gSU9SRVFfUkVBRDsKKwkJCXRlbXAgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0
Lk0zLnIzKTsKKwkJCWltbSA9IChpbnN0Lk0zLnMgPDwgMzEpIHwgKGluc3QuTTMuaSA8PCAzMCkg
fAorCQkJCShpbnN0Lk0zLmltbTcgPDwgMjMpOworCQkJdGVtcCArPSBpbW0gPj4gMjM7CisJCQl2
Y3B1X3NldF9ncih2Y3B1LCBpbnN0Lk0zLnIzLCB0ZW1wLCAwKTsKKworCQl9CisJfSBlbHNlIGlm
IChpbnN0Lk05Lm1ham9yID09IDYgJiYgaW5zdC5NOS54NiA9PSAweDNCCisJCQkJJiYgaW5zdC5N
OS5tID09IDAgJiYgaW5zdC5NOS54ID09IDApIHsKKwkJLyogRmxvYXRpbmctcG9pbnQgc3BpbGwq
LworCQlzdHJ1Y3QgaWE2NF9mcHJlZyB2OworCisJCWluc3RfdHlwZSA9IFNMX0ZMT0FUSU5HOwor
CQlkaXIgPSBJT1JFUV9XUklURTsKKwkJdmNwdV9nZXRfZnByZWcodmNwdSwgaW5zdC5NOS5mMiwg
JnYpOworCQkvKiBXcml0ZSBoaWdoIHdvcmQuIEZJWE1FOiB0aGlzIGlzIGEga2x1ZGdlISAgKi8K
KwkJdi51LmJpdHNbMV0gJj0gMHgzZmZmZjsKKwkJbW1pb19hY2Nlc3ModmNwdSwgcGFkciArIDgs
ICZ2LnUuYml0c1sxXSwgOCwgbWEsIElPUkVRX1dSSVRFKTsKKwkJZGF0YSA9IHYudS5iaXRzWzBd
OworCQlzaXplID0gMzsKKwl9IGVsc2UgaWYgKGluc3QuTTEwLm1ham9yID09IDcgJiYgaW5zdC5N
MTAueDYgPT0gMHgzQikgeworCQkvKiBGbG9hdGluZy1wb2ludCBzcGlsbCArIEltbSB1cGRhdGUg
Ki8KKwkJc3RydWN0IGlhNjRfZnByZWcgdjsKKworCQlpbnN0X3R5cGUgPSBTTF9GTE9BVElORzsK
KwkJZGlyID0gSU9SRVFfV1JJVEU7CisJCXZjcHVfZ2V0X2ZwcmVnKHZjcHUsIGluc3QuTTEwLmYy
LCAmdik7CisJCXRlbXAgPSB2Y3B1X2dldF9ncih2Y3B1LCBpbnN0Lk0xMC5yMyk7CisJCWltbSA9
IChpbnN0Lk0xMC5zIDw8IDMxKSB8IChpbnN0Lk0xMC5pIDw8IDMwKSB8CisJCQkoaW5zdC5NMTAu
aW1tNyA8PCAyMyk7CisJCXRlbXAgKz0gaW1tID4+IDIzOworCQl2Y3B1X3NldF9ncih2Y3B1LCBp
bnN0Lk0xMC5yMywgdGVtcCwgMCk7CisKKwkJLyogV3JpdGUgaGlnaCB3b3JkLkZJWE1FOiB0aGlz
IGlzIGEga2x1ZGdlISAgKi8KKwkJdi51LmJpdHNbMV0gJj0gMHgzZmZmZjsKKwkJbW1pb19hY2Nl
c3ModmNwdSwgcGFkciArIDgsICZ2LnUuYml0c1sxXSwgOCwgbWEsIElPUkVRX1dSSVRFKTsKKwkJ
ZGF0YSA9IHYudS5iaXRzWzBdOworCQlzaXplID0gMzsKKwl9IGVsc2UgaWYgKGluc3QuTTEwLm1h
am9yID09IDcgJiYgaW5zdC5NMTAueDYgPT0gMHgzMSkgeworCQkvKiBGbG9hdGluZy1wb2ludCBz
dGY4ICsgSW1tIHVwZGF0ZSAqLworCQlzdHJ1Y3QgaWE2NF9mcHJlZyB2OworCQlpbnN0X3R5cGUg
PSBTTF9GTE9BVElORzsKKwkJZGlyID0gSU9SRVFfV1JJVEU7CisJCXNpemUgPSAzOworCQl2Y3B1
X2dldF9mcHJlZyh2Y3B1LCBpbnN0Lk0xMC5mMiwgJnYpOworCQlkYXRhID0gdi51LmJpdHNbMF07
IC8qIFNpZ25pZmljYW5kLiAgKi8KKwkJdGVtcCA9IHZjcHVfZ2V0X2dyKHZjcHUsIGluc3QuTTEw
LnIzKTsKKwkJaW1tID0gKGluc3QuTTEwLnMgPDwgMzEpIHwgKGluc3QuTTEwLmkgPDwgMzApIHwK
KwkJCShpbnN0Lk0xMC5pbW03IDw8IDIzKTsKKwkJdGVtcCArPSBpbW0gPj4gMjM7CisJCXZjcHVf
c2V0X2dyKHZjcHUsIGluc3QuTTEwLnIzLCB0ZW1wLCAwKTsKKwl9IGVsc2UgaWYgKGluc3QuTTE1
Lm1ham9yID09IDcgJiYgaW5zdC5NMTUueDYgPj0gMHgyYworCQkJJiYgaW5zdC5NMTUueDYgPD0g
MHgyZikgeworCQl0ZW1wID0gdmNwdV9nZXRfZ3IodmNwdSwgaW5zdC5NMTUucjMpOworCQlpbW0g
PSAoaW5zdC5NMTUucyA8PCAzMSkgfCAoaW5zdC5NMTUuaSA8PCAzMCkgfAorCQkJKGluc3QuTTE1
LmltbTcgPDwgMjMpOworCQl0ZW1wICs9IGltbSA+PiAyMzsKKwkJdmNwdV9zZXRfZ3IodmNwdSwg
aW5zdC5NMTUucjMsIHRlbXAsIDApOworCisJCXZjcHVfaW5jcmVtZW50X2lpcCh2Y3B1KTsKKwkJ
cmV0dXJuOworCX0gZWxzZSBpZiAoaW5zdC5NMTIubWFqb3IgPT0gNiAmJiBpbnN0Lk0xMi5tID09
IDEKKwkJCSYmIGluc3QuTTEyLnggPT0gMSAmJiBpbnN0Lk0xMi54NiA9PSAxKSB7CisJCS8qIEZs
b2F0aW5nLXBvaW50IExvYWQgUGFpciArIEltbSBsZGZwOCBNMTIqLworCQlzdHJ1Y3QgaWE2NF9m
cHJlZyB2OworCisJCWluc3RfdHlwZSA9IFNMX0ZMT0FUSU5HOworCQlkaXIgPSBJT1JFUV9SRUFE
OworCQlzaXplID0gODsgICAgIC8qbGRmZCovCisJCW1taW9fYWNjZXNzKHZjcHUsIHBhZHIsICZk
YXRhLCBzaXplLCBtYSwgZGlyKTsKKwkJdi51LmJpdHNbMF0gPSBkYXRhOworCQl2LnUuYml0c1sx
XSA9IDB4MTAwM0U7CisJCXZjcHVfc2V0X2ZwcmVnKHZjcHUsIGluc3QuTTEyLmYxLCAmdik7CisJ
CXBhZHIgKz0gODsKKwkJbW1pb19hY2Nlc3ModmNwdSwgcGFkciwgJmRhdGEsIHNpemUsIG1hLCBk
aXIpOworCQl2LnUuYml0c1swXSA9IGRhdGE7CisJCXYudS5iaXRzWzFdID0gMHgxMDAzRTsKKwkJ
dmNwdV9zZXRfZnByZWcodmNwdSwgaW5zdC5NMTIuZjIsICZ2KTsKKwkJcGFkciArPSA4OworCQl2
Y3B1X3NldF9ncih2Y3B1LCBpbnN0Lk0xMi5yMywgcGFkciwgMCk7CisJCXZjcHVfaW5jcmVtZW50
X2lpcCh2Y3B1KTsKKwkJcmV0dXJuOworCX0gZWxzZSB7CisJCWluc3RfdHlwZSA9IC0xOworCQlw
YW5pY192bSh2Y3B1KTsKKwl9CisKKwlzaXplID0gMSA8PCBzaXplOworCWlmIChkaXIgPT0gSU9S
RVFfV1JJVEUpIHsKKwkJbW1pb19hY2Nlc3ModmNwdSwgcGFkciwgJmRhdGEsIHNpemUsIG1hLCBk
aXIpOworCX0gZWxzZSB7CisJCW1taW9fYWNjZXNzKHZjcHUsIHBhZHIsICZkYXRhLCBzaXplLCBt
YSwgZGlyKTsKKwkJaWYgKGluc3RfdHlwZSA9PSBTTF9JTlRFR0VSKSB7CisJCQl2Y3B1X3NldF9n
cih2Y3B1LCBpbnN0Lk0xLnIxLCBkYXRhLCAwKTsKKwkJfSBlbHNlIHsKKwkJCXBhbmljX3ZtKHZj
cHUpOworCQl9CisJfQorCXZjcHVfaW5jcmVtZW50X2lpcCh2Y3B1KTsKK30KLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C89309.3BECA437--
