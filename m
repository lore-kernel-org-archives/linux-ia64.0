From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 21 Dec 2001 04:19:36 +0000
Subject: [Linux-ia64] PATCH for modutils to fix relocation of IMM64 type
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C189D6.B2E58F00"
Message-Id: <marc-linux-ia64-105590698805713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C189D6.B2E58F00
Content-Type: text/plain;
	charset="ISO-8859-1"

Here is a patch to fix the relocation problem in insmod for IMM64 types
(also attached).

Thanks,
Asit
 

--- modutils-2.4.12/obj/obj_ia64.c      Tue Sep 25 21:50:45 2001
+++ modutils-2.4.12-akm/obj/obj_ia64.c  Wed Dec 12 17:18:31 2001
@@ -255,14 +255,15 @@
 {
     Elf64_Xword ins;

-    assert(slot == 1);
+    assert(slot == 2);
+
     ins = obj_ia64_ins_extract_from_bundle(bundle, slot);
-    ins &= 0xffffffee000101ff;
-    ins |= ((v & 0x8000000000000000) >> 28) | ((v & 0x0000000000200000)) |
+    ins &= 0xffffffe000101fff;
+    ins |= ((v & 0x8000000000000000) >> 27) | ((v & 0x0000000000200000)) |
           ((v & 0x00000000001f0000) <<  6) | ((v & 0x000000000000ff80) <<
20) |
           ((v & 0x000000000000007f) << 13);
     obj_ia64_ins_insert_in_bundle(bundle, slot, ins);
-    obj_ia64_ins_insert_in_bundle(bundle, ++slot, ((v & 0x7fffffffffc00000)
>> 22));
+    obj_ia64_ins_insert_in_bundle(bundle, --slot, ((v & 0x7fffffffffc00000)
>> 22));
     return obj_reloc_ok;
 }

 <<obj_ia64.diff>> 


------_=_NextPart_000_01C189D6.B2E58F00
Content-Type: application/octet-stream;
	name="obj_ia64.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="obj_ia64.diff"

--- modutils-2.4.12/obj/obj_ia64.c	Tue Sep 25 21:50:45 2001=0A=
+++ modutils-2.4.12-akm/obj/obj_ia64.c	Wed Dec 12 17:18:31 2001=0A=
@@ -255,14 +255,15 @@=0A=
 {=0A=
     Elf64_Xword ins;=0A=
 =0A=
-    assert(slot =3D=3D 1);=0A=
+    assert(slot =3D=3D 2);=0A=
+=0A=
     ins =3D obj_ia64_ins_extract_from_bundle(bundle, slot);=0A=
-    ins &=3D 0xffffffee000101ff;=0A=
-    ins |=3D ((v & 0x8000000000000000) >> 28) | ((v & =
0x0000000000200000)) |=0A=
+    ins &=3D 0xffffffe000101fff;=0A=
+    ins |=3D ((v & 0x8000000000000000) >> 27) | ((v & =
0x0000000000200000)) |=0A=
 	   ((v & 0x00000000001f0000) <<  6) | ((v & 0x000000000000ff80) << =
20) |=0A=
 	   ((v & 0x000000000000007f) << 13);=0A=
     obj_ia64_ins_insert_in_bundle(bundle, slot, ins);=0A=
-    obj_ia64_ins_insert_in_bundle(bundle, ++slot, ((v & =
0x7fffffffffc00000) >> 22));=0A=
+    obj_ia64_ins_insert_in_bundle(bundle, --slot, ((v & =
0x7fffffffffc00000) >> 22));=0A=
     return obj_reloc_ok;=0A=
 }=0A=
 =0A=

------_=_NextPart_000_01C189D6.B2E58F00--

