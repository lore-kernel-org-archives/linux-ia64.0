From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Sat, 18 Jan 2003 01:52:18 +0000
Subject: [Linux-ia64] [Patch] Fix in unwind.c
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2BE94.3B6AB86E"
Message-Id: <marc-linux-ia64-105590709805721@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2BE94.3B6AB86E
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Current code in unw_create_gate_table() looks like this:

start =3D (unsigned long) __start_gate_section - segbase;
end   =3D (unsigned long) __stop_gate_section - segbase;
size  =3D 0;
first =3D lookup(&unw.kernel_table, start);
for (entry =3D first; entry->start_offset < end; ++entry)
                size +=3D 3*8 + 8 + 8*UNW_LENGTH(*(u64 *) (segbase + =
entry->info_offset));

Code starts with first unwind kernel table entry for the gate page and =
goes through all the gate page unwind table entries. Assume if all the =
gate page unwind table entries comes to the end of kernel unwind =
table(typically this is what happens because of  the order in =
vmlinux.lds.S), then there is a chance that we go past beyond the kernel =
unwind table and resulting in a fault while we access "segbase +  =
entry->info_offset".=20

Attached/appended patch fixes this problem.

thanks,
suresh

diff -Nru linux-2.5.52/arch/ia64/kernel/unwind.c~ =
linux-2.5.52/arch/ia64/kernel/unwind.c
--- linux-2.5.52/arch/ia64/kernel/unwind.c~	Fri Jan 17 14:53:48 2003
+++ linux-2.5.52/arch/ia64/kernel/unwind.c	Fri Jan 17 15:26:58 2003
@@ -1998,6 +1998,7 @@
 	extern char __start_gate_section[], __stop_gate_section[];
 	unsigned long *lp, start, end, segbase =3D =
unw.kernel_table.segment_base;
 	const struct unw_table_entry *entry, *first;
+	extern int ia64_unw_end;
 	size_t info_size, size;
 	char *info;
=20
@@ -2006,7 +2007,10 @@
 	size  =3D 0;
 	first =3D lookup(&unw.kernel_table, start);
=20
-	for (entry =3D first; entry->start_offset < end; ++entry)
+	for (entry =3D first;=20
+	     (entry < (struct unw_table_entry *) &ia64_unw_end) &&=20
+	     (entry->start_offset < end);=20
+	     ++entry)
 		size +=3D 3*8 + 8 + 8*UNW_LENGTH(*(u64 *) (segbase + =
entry->info_offset));
 	size +=3D 8;	/* reserve space for "end of table" marker */
=20
@@ -2021,7 +2025,10 @@
 	lp =3D unw.gate_table;
 	info =3D (char *) unw.gate_table + size;
=20
-	for (entry =3D first; entry->start_offset < end; ++entry, lp +=3D 3) {
+	for (entry =3D first;=20
+	     (entry < (struct unw_table_entry *) &ia64_unw_end) &&=20
+	     (entry->start_offset < end);=20
+	     ++entry, lp +=3D 3) {
 		info_size =3D 8 + 8*UNW_LENGTH(*(u64 *) (segbase + =
entry->info_offset));
 		info -=3D info_size;
 		memcpy(info, (char *) segbase + entry->info_offset, info_size);


------_=_NextPart_001_01C2BE94.3B6AB86E
Content-Type: application/octet-stream;
	name="unwind.c.diff"
Content-Transfer-Encoding: base64
Content-Description: unwind.c.diff
Content-Disposition: attachment;
	filename="unwind.c.diff"

ZGlmZiAtTnJ1IGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQva2VybmVsL3Vud2luZC5jfiBsaW51eC0y
LjUuNTIvYXJjaC9pYTY0L2tlcm5lbC91bndpbmQuYw0KLS0tIGxpbnV4LTIuNS41Mi9hcmNoL2lh
NjQva2VybmVsL3Vud2luZC5jfglGcmkgSmFuIDE3IDE0OjUzOjQ4IDIwMDMNCisrKyBsaW51eC0y
LjUuNTIvYXJjaC9pYTY0L2tlcm5lbC91bndpbmQuYwlGcmkgSmFuIDE3IDE1OjI2OjU4IDIwMDMN
CkBAIC0xOTk4LDYgKzE5OTgsNyBAQA0KIAlleHRlcm4gY2hhciBfX3N0YXJ0X2dhdGVfc2VjdGlv
bltdLCBfX3N0b3BfZ2F0ZV9zZWN0aW9uW107DQogCXVuc2lnbmVkIGxvbmcgKmxwLCBzdGFydCwg
ZW5kLCBzZWdiYXNlID0gdW53Lmtlcm5lbF90YWJsZS5zZWdtZW50X2Jhc2U7DQogCWNvbnN0IHN0
cnVjdCB1bndfdGFibGVfZW50cnkgKmVudHJ5LCAqZmlyc3Q7DQorCWV4dGVybiBpbnQgaWE2NF91
bndfZW5kOw0KIAlzaXplX3QgaW5mb19zaXplLCBzaXplOw0KIAljaGFyICppbmZvOw0KIA0KQEAg
LTIwMDYsNyArMjAwNywxMCBAQA0KIAlzaXplICA9IDA7DQogCWZpcnN0ID0gbG9va3VwKCZ1bncu
a2VybmVsX3RhYmxlLCBzdGFydCk7DQogDQotCWZvciAoZW50cnkgPSBmaXJzdDsgZW50cnktPnN0
YXJ0X29mZnNldCA8IGVuZDsgKytlbnRyeSkNCisJZm9yIChlbnRyeSA9IGZpcnN0OyANCisJICAg
ICAoZW50cnkgPCAoc3RydWN0IHVud190YWJsZV9lbnRyeSAqKSAmaWE2NF91bndfZW5kKSAmJiAN
CisJICAgICAoZW50cnktPnN0YXJ0X29mZnNldCA8IGVuZCk7IA0KKwkgICAgICsrZW50cnkpDQog
CQlzaXplICs9IDMqOCArIDggKyA4KlVOV19MRU5HVEgoKih1NjQgKikgKHNlZ2Jhc2UgKyBlbnRy
eS0+aW5mb19vZmZzZXQpKTsNCiAJc2l6ZSArPSA4OwkvKiByZXNlcnZlIHNwYWNlIGZvciAiZW5k
IG9mIHRhYmxlIiBtYXJrZXIgKi8NCiANCkBAIC0yMDIxLDcgKzIwMjUsMTAgQEANCiAJbHAgPSB1
bncuZ2F0ZV90YWJsZTsNCiAJaW5mbyA9IChjaGFyICopIHVudy5nYXRlX3RhYmxlICsgc2l6ZTsN
CiANCi0JZm9yIChlbnRyeSA9IGZpcnN0OyBlbnRyeS0+c3RhcnRfb2Zmc2V0IDwgZW5kOyArK2Vu
dHJ5LCBscCArPSAzKSB7DQorCWZvciAoZW50cnkgPSBmaXJzdDsgDQorCSAgICAgKGVudHJ5IDwg
KHN0cnVjdCB1bndfdGFibGVfZW50cnkgKikgJmlhNjRfdW53X2VuZCkgJiYgDQorCSAgICAgKGVu
dHJ5LT5zdGFydF9vZmZzZXQgPCBlbmQpOyANCisJICAgICArK2VudHJ5LCBscCArPSAzKSB7DQog
CQlpbmZvX3NpemUgPSA4ICsgOCpVTldfTEVOR1RIKCoodTY0ICopIChzZWdiYXNlICsgZW50cnkt
PmluZm9fb2Zmc2V0KSk7DQogCQlpbmZvIC09IGluZm9fc2l6ZTsNCiAJCW1lbWNweShpbmZvLCAo
Y2hhciAqKSBzZWdiYXNlICsgZW50cnktPmluZm9fb2Zmc2V0LCBpbmZvX3NpemUpOw0K

------_=_NextPart_001_01C2BE94.3B6AB86E--

