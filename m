From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Mon, 24 Feb 2003 18:20:12 +0000
Subject: [Linux-ia64] [Patch] 1/2 fix for generic kernel
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2DC31.5EE7C898"
Message-Id: <marc-linux-ia64-105590709805917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2DC31.5EE7C898
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Current 2.5 kernels are broken with CONFIG_IA64_GENERIC option. Two =
unused members are still remaining in the structure, resulting in =
corruption of structure elements during the MACHVEC_INIT initialization. =
Attached patch fixes this problem.

thanks,
suresh

diff -Nru linux-2.5.60/arch/ia64/kernel/machvec.c =
linux/arch/ia64/kernel/machvec.c
--- linux-2.5.60/arch/ia64/kernel/machvec.c	Thu Feb 20 11:10:53 2003
+++ linux/arch/ia64/kernel/machvec.c	Thu Feb 20 10:35:33 2003
@@ -10,19 +10,6 @@
=20
 struct ia64_machine_vector ia64_mv;
=20
-/*
- * Most platforms use this routine for mapping page frame addresses =
into a memory map
- * index.
- *
- * Note: we can't use __pa() because map_nr_dense(X) MUST map to =
something >=3D max_mapnr if
- * X is outside the identity mapped kernel space.
- */
-unsigned long
-map_nr_dense (unsigned long addr)
-{
-	return (addr - PAGE_OFFSET) >> PAGE_SHIFT;
-}
-
 static struct ia64_machine_vector *
 lookup_machvec (const char *name)
 {
diff -Nru linux-2.5.60/include/asm-ia64/machvec.h =
linux/include/asm-ia64/machvec.h
--- linux-2.5.60/include/asm-ia64/machvec.h	Thu Feb 20 11:11:10 2003
+++ linux/include/asm-ia64/machvec.h	Thu Feb 20 13:51:48 2003
@@ -23,8 +23,6 @@
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t(void);
 typedef void ia64_mv_irq_init_t (void);
-typedef void ia64_mv_pci_fixup_t (int);
-typedef unsigned long ia64_mv_map_nr_t (unsigned long);
 typedef void ia64_mv_mca_init_t (void);
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
@@ -120,8 +118,6 @@
 	ia64_mv_setup_t *setup;
 	ia64_mv_cpu_init_t *cpu_init;
 	ia64_mv_irq_init_t *irq_init;
-	ia64_mv_pci_fixup_t *pci_fixup;
-	ia64_mv_map_nr_t *map_nr;
 	ia64_mv_mca_init_t *mca_init;
 	ia64_mv_mca_handler_t *mca_handler;
 	ia64_mv_cmci_handler_t *cmci_handler;
diff -Nru linux-2.5.60/include/asm-ia64/machvec_dig.h =
linux/include/asm-ia64/machvec_dig.h
--- linux-2.5.60/include/asm-ia64/machvec_dig.h	Thu Feb 20 11:11:48 2003
+++ linux/include/asm-ia64/machvec_dig.h	Thu Feb 20 11:14:25 2003
@@ -3,8 +3,6 @@
=20
 extern ia64_mv_setup_t dig_setup;
 extern ia64_mv_irq_init_t dig_irq_init;
-extern ia64_mv_pci_fixup_t iosapic_pci_fixup;
-extern ia64_mv_map_nr_t map_nr_dense;
=20
 /*
  * This stuff has dual use!
diff -Nru linux-2.5.60/include/asm-ia64/machvec_hpsim.h =
linux/include/asm-ia64/machvec_hpsim.h
--- linux-2.5.60/include/asm-ia64/machvec_hpsim.h	Thu Feb 20 11:11:59 =
2003
+++ linux/include/asm-ia64/machvec_hpsim.h	Thu Feb 20 11:14:12 2003
@@ -3,7 +3,6 @@
=20
 extern ia64_mv_setup_t hpsim_setup;
 extern ia64_mv_irq_init_t hpsim_irq_init;
-extern ia64_mv_map_nr_t map_nr_dense;
=20
 /*
  * This stuff has dual use!
diff -Nru linux-2.5.60/include/asm-ia64/machvec_hpzx1.h =
linux/include/asm-ia64/machvec_hpzx1.h
--- linux-2.5.60/include/asm-ia64/machvec_hpzx1.h	Thu Feb 20 11:11:35 =
2003
+++ linux/include/asm-ia64/machvec_hpzx1.h	Thu Feb 20 11:31:21 2003
@@ -2,8 +2,6 @@
 #define _ASM_IA64_MACHVEC_HPZX1_h
=20
 extern ia64_mv_setup_t dig_setup;
-extern ia64_mv_pci_fixup_t hpzx1_pci_fixup;
-extern ia64_mv_map_nr_t map_nr_dense;
 extern ia64_mv_pci_alloc_consistent sba_alloc_consistent;
 extern ia64_mv_pci_free_consistent sba_free_consistent;
 extern ia64_mv_pci_map_single sba_map_single;
diff -Nru linux-2.5.60/include/asm-ia64/machvec_sn1.h =
linux/include/asm-ia64/machvec_sn1.h
--- linux-2.5.60/include/asm-ia64/machvec_sn1.h	Mon Feb 10 10:38:44 2003
+++ linux/include/asm-ia64/machvec_sn1.h	Thu Feb 20 11:34:17 2003
@@ -36,10 +36,8 @@
 extern ia64_mv_setup_t sn1_setup;
 extern ia64_mv_cpu_init_t sn_cpu_init;
 extern ia64_mv_irq_init_t sn1_irq_init;
-extern ia64_mv_map_nr_t sn1_map_nr;
 extern ia64_mv_send_ipi_t sn1_send_IPI;
 extern ia64_mv_global_tlb_purge_t sn1_global_tlb_purge;
-extern ia64_mv_pci_fixup_t sn1_pci_fixup;
 extern ia64_mv_inb_t sn1_inb;
 extern ia64_mv_inw_t sn1_inw;
 extern ia64_mv_inl_t sn1_inl;
diff -Nru linux-2.5.60/include/asm-ia64/machvec_sn2.h =
linux/include/asm-ia64/machvec_sn2.h
--- linux-2.5.60/include/asm-ia64/machvec_sn2.h	Mon Feb 10 10:38:20 2003
+++ linux/include/asm-ia64/machvec_sn2.h	Thu Feb 20 11:59:23 2003
@@ -36,13 +36,11 @@
 extern ia64_mv_setup_t sn_setup;
 extern ia64_mv_cpu_init_t sn_cpu_init;
 extern ia64_mv_irq_init_t sn_irq_init;
-extern ia64_mv_map_nr_t sn2_map_nr;
 extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
-extern ia64_mv_pci_fixup_t sn_pci_fixup;
 extern ia64_mv_inb_t sn_inb;
 extern ia64_mv_inw_t sn_inw;
 extern ia64_mv_inl_t sn_inl;
@@ -72,10 +70,8 @@
 #define platform_setup			sn_setup
 #define platform_cpu_init		sn_cpu_init
 #define platform_irq_init		sn_irq_init
-#define platform_map_nr			sn2_map_nr
 #define platform_send_ipi		sn2_send_IPI
 #define platform_global_tlb_purge       sn2_global_tlb_purge
-#define platform_pci_fixup		sn_pci_fixup
 #define platform_inb			sn_inb
 #define platform_inw			sn_inw
 #define platform_inl			sn_inl


------_=_NextPart_001_01C2DC31.5EE7C898
Content-Type: application/octet-stream;
	name="generic.diff"
Content-Transfer-Encoding: base64
Content-Description: generic.diff
Content-Disposition: attachment;
	filename="generic.diff"

ZGlmZiAtTnJ1IGxpbnV4LTIuNS42MC9hcmNoL2lhNjQva2VybmVsL21hY2h2ZWMuYyBsaW51eC9h
cmNoL2lhNjQva2VybmVsL21hY2h2ZWMuYw0KLS0tIGxpbnV4LTIuNS42MC9hcmNoL2lhNjQva2Vy
bmVsL21hY2h2ZWMuYwlUaHUgRmViIDIwIDExOjEwOjUzIDIwMDMNCisrKyBsaW51eC9hcmNoL2lh
NjQva2VybmVsL21hY2h2ZWMuYwlUaHUgRmViIDIwIDEwOjM1OjMzIDIwMDMNCkBAIC0xMCwxOSAr
MTAsNiBAQA0KIA0KIHN0cnVjdCBpYTY0X21hY2hpbmVfdmVjdG9yIGlhNjRfbXY7DQogDQotLyoN
Ci0gKiBNb3N0IHBsYXRmb3JtcyB1c2UgdGhpcyByb3V0aW5lIGZvciBtYXBwaW5nIHBhZ2UgZnJh
bWUgYWRkcmVzc2VzIGludG8gYSBtZW1vcnkgbWFwDQotICogaW5kZXguDQotICoNCi0gKiBOb3Rl
OiB3ZSBjYW4ndCB1c2UgX19wYSgpIGJlY2F1c2UgbWFwX25yX2RlbnNlKFgpIE1VU1QgbWFwIHRv
IHNvbWV0aGluZyA+PSBtYXhfbWFwbnIgaWYNCi0gKiBYIGlzIG91dHNpZGUgdGhlIGlkZW50aXR5
IG1hcHBlZCBrZXJuZWwgc3BhY2UuDQotICovDQotdW5zaWduZWQgbG9uZw0KLW1hcF9ucl9kZW5z
ZSAodW5zaWduZWQgbG9uZyBhZGRyKQ0KLXsNCi0JcmV0dXJuIChhZGRyIC0gUEFHRV9PRkZTRVQp
ID4+IFBBR0VfU0hJRlQ7DQotfQ0KLQ0KIHN0YXRpYyBzdHJ1Y3QgaWE2NF9tYWNoaW5lX3ZlY3Rv
ciAqDQogbG9va3VwX21hY2h2ZWMgKGNvbnN0IGNoYXIgKm5hbWUpDQogew0KZGlmZiAtTnJ1IGxp
bnV4LTIuNS42MC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWMuaCBsaW51eC9pbmNsdWRlL2FzbS1p
YTY0L21hY2h2ZWMuaA0KLS0tIGxpbnV4LTIuNS42MC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWMu
aAlUaHUgRmViIDIwIDExOjExOjEwIDIwMDMNCisrKyBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L21h
Y2h2ZWMuaAlUaHUgRmViIDIwIDEzOjUxOjQ4IDIwMDMNCkBAIC0yMyw4ICsyMyw2IEBADQogdHlw
ZWRlZiB2b2lkIGlhNjRfbXZfc2V0dXBfdCAoY2hhciAqKik7DQogdHlwZWRlZiB2b2lkIGlhNjRf
bXZfY3B1X2luaXRfdCh2b2lkKTsNCiB0eXBlZGVmIHZvaWQgaWE2NF9tdl9pcnFfaW5pdF90ICh2
b2lkKTsNCi10eXBlZGVmIHZvaWQgaWE2NF9tdl9wY2lfZml4dXBfdCAoaW50KTsNCi10eXBlZGVm
IHVuc2lnbmVkIGxvbmcgaWE2NF9tdl9tYXBfbnJfdCAodW5zaWduZWQgbG9uZyk7DQogdHlwZWRl
ZiB2b2lkIGlhNjRfbXZfbWNhX2luaXRfdCAodm9pZCk7DQogdHlwZWRlZiB2b2lkIGlhNjRfbXZf
bWNhX2hhbmRsZXJfdCAodm9pZCk7DQogdHlwZWRlZiB2b2lkIGlhNjRfbXZfY21jaV9oYW5kbGVy
X3QgKGludCwgdm9pZCAqLCBzdHJ1Y3QgcHRfcmVncyAqKTsNCkBAIC0xMjAsOCArMTE4LDYgQEAN
CiAJaWE2NF9tdl9zZXR1cF90ICpzZXR1cDsNCiAJaWE2NF9tdl9jcHVfaW5pdF90ICpjcHVfaW5p
dDsNCiAJaWE2NF9tdl9pcnFfaW5pdF90ICppcnFfaW5pdDsNCi0JaWE2NF9tdl9wY2lfZml4dXBf
dCAqcGNpX2ZpeHVwOw0KLQlpYTY0X212X21hcF9ucl90ICptYXBfbnI7DQogCWlhNjRfbXZfbWNh
X2luaXRfdCAqbWNhX2luaXQ7DQogCWlhNjRfbXZfbWNhX2hhbmRsZXJfdCAqbWNhX2hhbmRsZXI7
DQogCWlhNjRfbXZfY21jaV9oYW5kbGVyX3QgKmNtY2lfaGFuZGxlcjsNCmRpZmYgLU5ydSBsaW51
eC0yLjUuNjAvaW5jbHVkZS9hc20taWE2NC9tYWNodmVjX2RpZy5oIGxpbnV4L2luY2x1ZGUvYXNt
LWlhNjQvbWFjaHZlY19kaWcuaA0KLS0tIGxpbnV4LTIuNS42MC9pbmNsdWRlL2FzbS1pYTY0L21h
Y2h2ZWNfZGlnLmgJVGh1IEZlYiAyMCAxMToxMTo0OCAyMDAzDQorKysgbGludXgvaW5jbHVkZS9h
c20taWE2NC9tYWNodmVjX2RpZy5oCVRodSBGZWIgMjAgMTE6MTQ6MjUgMjAwMw0KQEAgLTMsOCAr
Myw2IEBADQogDQogZXh0ZXJuIGlhNjRfbXZfc2V0dXBfdCBkaWdfc2V0dXA7DQogZXh0ZXJuIGlh
NjRfbXZfaXJxX2luaXRfdCBkaWdfaXJxX2luaXQ7DQotZXh0ZXJuIGlhNjRfbXZfcGNpX2ZpeHVw
X3QgaW9zYXBpY19wY2lfZml4dXA7DQotZXh0ZXJuIGlhNjRfbXZfbWFwX25yX3QgbWFwX25yX2Rl
bnNlOw0KIA0KIC8qDQogICogVGhpcyBzdHVmZiBoYXMgZHVhbCB1c2UhDQpkaWZmIC1OcnUgbGlu
dXgtMi41LjYwL2luY2x1ZGUvYXNtLWlhNjQvbWFjaHZlY19ocHNpbS5oIGxpbnV4L2luY2x1ZGUv
YXNtLWlhNjQvbWFjaHZlY19ocHNpbS5oDQotLS0gbGludXgtMi41LjYwL2luY2x1ZGUvYXNtLWlh
NjQvbWFjaHZlY19ocHNpbS5oCVRodSBGZWIgMjAgMTE6MTE6NTkgMjAwMw0KKysrIGxpbnV4L2lu
Y2x1ZGUvYXNtLWlhNjQvbWFjaHZlY19ocHNpbS5oCVRodSBGZWIgMjAgMTE6MTQ6MTIgMjAwMw0K
QEAgLTMsNyArMyw2IEBADQogDQogZXh0ZXJuIGlhNjRfbXZfc2V0dXBfdCBocHNpbV9zZXR1cDsN
CiBleHRlcm4gaWE2NF9tdl9pcnFfaW5pdF90IGhwc2ltX2lycV9pbml0Ow0KLWV4dGVybiBpYTY0
X212X21hcF9ucl90IG1hcF9ucl9kZW5zZTsNCiANCiAvKg0KICAqIFRoaXMgc3R1ZmYgaGFzIGR1
YWwgdXNlIQ0KZGlmZiAtTnJ1IGxpbnV4LTIuNS42MC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWNf
aHB6eDEuaCBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWNfaHB6eDEuaA0KLS0tIGxpbnV4
LTIuNS42MC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWNfaHB6eDEuaAlUaHUgRmViIDIwIDExOjEx
OjM1IDIwMDMNCisrKyBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWNfaHB6eDEuaAlUaHUg
RmViIDIwIDExOjMxOjIxIDIwMDMNCkBAIC0yLDggKzIsNiBAQA0KICNkZWZpbmUgX0FTTV9JQTY0
X01BQ0hWRUNfSFBaWDFfaA0KIA0KIGV4dGVybiBpYTY0X212X3NldHVwX3QgZGlnX3NldHVwOw0K
LWV4dGVybiBpYTY0X212X3BjaV9maXh1cF90IGhwengxX3BjaV9maXh1cDsNCi1leHRlcm4gaWE2
NF9tdl9tYXBfbnJfdCBtYXBfbnJfZGVuc2U7DQogZXh0ZXJuIGlhNjRfbXZfcGNpX2FsbG9jX2Nv
bnNpc3RlbnQgc2JhX2FsbG9jX2NvbnNpc3RlbnQ7DQogZXh0ZXJuIGlhNjRfbXZfcGNpX2ZyZWVf
Y29uc2lzdGVudCBzYmFfZnJlZV9jb25zaXN0ZW50Ow0KIGV4dGVybiBpYTY0X212X3BjaV9tYXBf
c2luZ2xlIHNiYV9tYXBfc2luZ2xlOw0KZGlmZiAtTnJ1IGxpbnV4LTIuNS42MC9pbmNsdWRlL2Fz
bS1pYTY0L21hY2h2ZWNfc24xLmggbGludXgvaW5jbHVkZS9hc20taWE2NC9tYWNodmVjX3NuMS5o
DQotLS0gbGludXgtMi41LjYwL2luY2x1ZGUvYXNtLWlhNjQvbWFjaHZlY19zbjEuaAlNb24gRmVi
IDEwIDEwOjM4OjQ0IDIwMDMNCisrKyBsaW51eC9pbmNsdWRlL2FzbS1pYTY0L21hY2h2ZWNfc24x
LmgJVGh1IEZlYiAyMCAxMTozNDoxNyAyMDAzDQpAQCAtMzYsMTAgKzM2LDggQEANCiBleHRlcm4g
aWE2NF9tdl9zZXR1cF90IHNuMV9zZXR1cDsNCiBleHRlcm4gaWE2NF9tdl9jcHVfaW5pdF90IHNu
X2NwdV9pbml0Ow0KIGV4dGVybiBpYTY0X212X2lycV9pbml0X3Qgc24xX2lycV9pbml0Ow0KLWV4
dGVybiBpYTY0X212X21hcF9ucl90IHNuMV9tYXBfbnI7DQogZXh0ZXJuIGlhNjRfbXZfc2VuZF9p
cGlfdCBzbjFfc2VuZF9JUEk7DQogZXh0ZXJuIGlhNjRfbXZfZ2xvYmFsX3RsYl9wdXJnZV90IHNu
MV9nbG9iYWxfdGxiX3B1cmdlOw0KLWV4dGVybiBpYTY0X212X3BjaV9maXh1cF90IHNuMV9wY2lf
Zml4dXA7DQogZXh0ZXJuIGlhNjRfbXZfaW5iX3Qgc24xX2luYjsNCiBleHRlcm4gaWE2NF9tdl9p
bndfdCBzbjFfaW53Ow0KIGV4dGVybiBpYTY0X212X2lubF90IHNuMV9pbmw7DQpkaWZmIC1OcnUg
bGludXgtMi41LjYwL2luY2x1ZGUvYXNtLWlhNjQvbWFjaHZlY19zbjIuaCBsaW51eC9pbmNsdWRl
L2FzbS1pYTY0L21hY2h2ZWNfc24yLmgNCi0tLSBsaW51eC0yLjUuNjAvaW5jbHVkZS9hc20taWE2
NC9tYWNodmVjX3NuMi5oCU1vbiBGZWIgMTAgMTA6Mzg6MjAgMjAwMw0KKysrIGxpbnV4L2luY2x1
ZGUvYXNtLWlhNjQvbWFjaHZlY19zbjIuaAlUaHUgRmViIDIwIDExOjU5OjIzIDIwMDMNCkBAIC0z
NiwxMyArMzYsMTEgQEANCiBleHRlcm4gaWE2NF9tdl9zZXR1cF90IHNuX3NldHVwOw0KIGV4dGVy
biBpYTY0X212X2NwdV9pbml0X3Qgc25fY3B1X2luaXQ7DQogZXh0ZXJuIGlhNjRfbXZfaXJxX2lu
aXRfdCBzbl9pcnFfaW5pdDsNCi1leHRlcm4gaWE2NF9tdl9tYXBfbnJfdCBzbjJfbWFwX25yOw0K
IGV4dGVybiBpYTY0X212X3NlbmRfaXBpX3Qgc24yX3NlbmRfSVBJOw0KIGV4dGVybiBpYTY0X212
X2dsb2JhbF90bGJfcHVyZ2VfdCBzbjJfZ2xvYmFsX3RsYl9wdXJnZTsNCiBleHRlcm4gaWE2NF9t
dl9pcnFfZGVzYyBzbl9pcnFfZGVzYzsNCiBleHRlcm4gaWE2NF9tdl9pcnFfdG9fdmVjdG9yIHNu
X2lycV90b192ZWN0b3I7DQogZXh0ZXJuIGlhNjRfbXZfbG9jYWxfdmVjdG9yX3RvX2lycSBzbl9s
b2NhbF92ZWN0b3JfdG9faXJxOw0KLWV4dGVybiBpYTY0X212X3BjaV9maXh1cF90IHNuX3BjaV9m
aXh1cDsNCiBleHRlcm4gaWE2NF9tdl9pbmJfdCBzbl9pbmI7DQogZXh0ZXJuIGlhNjRfbXZfaW53
X3Qgc25faW53Ow0KIGV4dGVybiBpYTY0X212X2lubF90IHNuX2lubDsNCkBAIC03MiwxMCArNzAs
OCBAQA0KICNkZWZpbmUgcGxhdGZvcm1fc2V0dXAJCQlzbl9zZXR1cA0KICNkZWZpbmUgcGxhdGZv
cm1fY3B1X2luaXQJCXNuX2NwdV9pbml0DQogI2RlZmluZSBwbGF0Zm9ybV9pcnFfaW5pdAkJc25f
aXJxX2luaXQNCi0jZGVmaW5lIHBsYXRmb3JtX21hcF9ucgkJCXNuMl9tYXBfbnINCiAjZGVmaW5l
IHBsYXRmb3JtX3NlbmRfaXBpCQlzbjJfc2VuZF9JUEkNCiAjZGVmaW5lIHBsYXRmb3JtX2dsb2Jh
bF90bGJfcHVyZ2UgICAgICAgc24yX2dsb2JhbF90bGJfcHVyZ2UNCi0jZGVmaW5lIHBsYXRmb3Jt
X3BjaV9maXh1cAkJc25fcGNpX2ZpeHVwDQogI2RlZmluZSBwbGF0Zm9ybV9pbmIJCQlzbl9pbmIN
CiAjZGVmaW5lIHBsYXRmb3JtX2ludwkJCXNuX2ludw0KICNkZWZpbmUgcGxhdGZvcm1faW5sCQkJ
c25faW5sDQo=

------_=_NextPart_001_01C2DC31.5EE7C898--

