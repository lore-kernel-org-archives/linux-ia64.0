From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Tue, 23 Aug 2011 19:48:23 +0000
Subject: [PATCH] agp/hp-agp: Allow binding user memory to the AGP GART
Message-Id: <CAA9xbM6hxRUzLw9dsn0h2kz9BrYBLJqRXCScsB5pTb6h-tgs+w@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="00151747614a7cb13204ab317a8b"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--00151747614a7cb13204ab317a8b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

dmesg reports:
[ =A0 29.365973] [TTM] AGP Bind memory failed.
[ =A0 29.366015] radeon 0000:80:00.0: object_init failed for (4096, 0x00000=
002)
[ =A0 29.366052] radeon 0000:80:00.0: (-22) create WB bo failed
[ =A0 29.366087] radeon 0000:80:00.0: Disabling GPU acceleration
[ =A0 29.366124] [drm] radeon: cp finalized
[ =A0 29.366168] [drm] radeon: cp finalized
[ =A0 29.366210] [TTM] Finalizing pool allocator.
[ =A0 29.366924] [TTM] Zone =A0kernel: Used memory at exit: 0 kiB.
[ =A0 29.366961] [TTM] Zone =A0 dma32: Used memory at exit: 0 kiB.
[ =A0 29.366996] [drm] radeon: ttm finalized
[ =A0 29.367030] [drm] Forcing AGP to PCI mode

This patch allows binding user memory to the AGP GART on zx1-based
systems. dmesg thus no more complains about AGP bind memory failure,
disabled GPU acceleration or AGP mode forced to PCI.

Original work from Francisco Jerez in agp/amd-k7
(https://lkml.org/lkml/2010/10/15/469).

Signed-off-by: Tony Luck <tony.luck@intel.com>
Tested-by: =C9meric Maschino <emeric.maschino@gmail.com>
---
--- a/drivers/char/agp/hp-agp.c	2011-07-22 04:17:23.000000000 +0200
+++ b/drivers/char/agp/hp-agp.c	2011-08-20 01:16:47.000000000 +0200
@@ -336,7 +336,8 @@
 	off_t j, io_pg_start;
 	int io_pg_count;

-	if (type !=3D 0 || mem->type !=3D 0) {
+	if (type !=3D mem->type ||
+		agp_bridge->driver->agp_type_to_mask_type(agp_bridge, type)) {
 		return -EINVAL;
 	}

@@ -380,7 +381,8 @@
 	struct _hp_private *hp =3D &hp_private;
 	int i, io_pg_start, io_pg_count;

-	if (type !=3D 0 || mem->type !=3D 0) {
+	if (type !=3D mem->type ||
+		agp_bridge->driver->agp_type_to_mask_type(agp_bridge, type)) {
 		return -EINVAL;
 	}

Feel free to reformat to conform to Linux kernel coding rules if needed.

Thank you,

     =C9meric

--00151747614a7cb13204ab317a8b
Content-Type: text/x-diff; charset=US-ASCII; name="hp-agp.c.diff"
Content-Disposition: attachment; filename="hp-agp.c.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_grpadfr30

LS0tIGEvZHJpdmVycy9jaGFyL2FncC9ocC1hZ3AuYwkyMDExLTA3LTIyIDA0OjE3OjIzLjAwMDAw
MDAwMCArMDIwMAorKysgYi9kcml2ZXJzL2NoYXIvYWdwL2hwLWFncC5jCTIwMTEtMDgtMjAgMDE6
MTY6NDcuMDAwMDAwMDAwICswMjAwCkBAIC0zMzYsNyArMzM2LDggQEAKIAlvZmZfdCBqLCBpb19w
Z19zdGFydDsKIAlpbnQgaW9fcGdfY291bnQ7CiAKLQlpZiAodHlwZSAhPSAwIHx8IG1lbS0+dHlw
ZSAhPSAwKSB7CisJaWYgKHR5cGUgIT0gbWVtLT50eXBlIHx8CisJCWFncF9icmlkZ2UtPmRyaXZl
ci0+YWdwX3R5cGVfdG9fbWFza190eXBlKGFncF9icmlkZ2UsIHR5cGUpKSB7CiAJCXJldHVybiAt
RUlOVkFMOwogCX0KIApAQCAtMzgwLDcgKzM4MSw4IEBACiAJc3RydWN0IF9ocF9wcml2YXRlICpo
cCA9ICZocF9wcml2YXRlOwogCWludCBpLCBpb19wZ19zdGFydCwgaW9fcGdfY291bnQ7CiAKLQlp
ZiAodHlwZSAhPSAwIHx8IG1lbS0+dHlwZSAhPSAwKSB7CisJaWYgKHR5cGUgIT0gbWVtLT50eXBl
IHx8CisJCWFncF9icmlkZ2UtPmRyaXZlci0+YWdwX3R5cGVfdG9fbWFza190eXBlKGFncF9icmlk
Z2UsIHR5cGUpKSB7CiAJCXJldHVybiAtRUlOVkFMOwogCX0KIAo=
--00151747614a7cb13204ab317a8b--
