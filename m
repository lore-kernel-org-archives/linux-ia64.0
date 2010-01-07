From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Jan 2010 19:58:51 +0000
Subject: [PATCH 1/2] ACPICA: acpi_get_object_info(): fixup array -> pointer
Message-Id: <20100107195851.1790.25742.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Commit 15b8dd53f5ffa changed the string in info->hardware_id from a static
array to a pointer and added a length field.  But instead of changing
"sizeof(array)" to "length", we changed it to "sizeof(length)" (=3D 4),
which corrupts the string we're trying to null-terminate.

We no longer even need to null-terminate the string, but we *do* need to
check whether we found a HID.  If there's no HID, we used to have an empty
array, but now we have a null pointer.

The combination of these defects causes this oops:

  Unable to handle kernel NULL pointer dereference (address 000000000000000=
3)
  modprobe[895]: Oops 8804682956800 [1]
  ip is at zx1_gart_probe+0xd0/0xcc0 [hp_agp]

  http://marc.info/?l=3Dlinux-ia64&m=126264484923647&w=3D2

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Reported-by: =C3=89meric Maschino <emeric.maschino@gmail.com>
---

 drivers/char/agp/hp-agp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
index 9047b27..dc8a6f7 100644
--- a/drivers/char/agp/hp-agp.c
+++ b/drivers/char/agp/hp-agp.c
@@ -488,9 +488,8 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *conte=
xt, void **ret)
 	handle =3D obj;
 	do {
 		status =3D acpi_get_object_info(handle, &info);
-		if (ACPI_SUCCESS(status)) {
+		if (ACPI_SUCCESS(status) && (info->valid & ACPI_VALID_HID)) {
 			/* TBD check _CID also */
-			info->hardware_id.string[sizeof(info->hardware_id.length)-1] =3D '\0';
 			match =3D (strcmp(info->hardware_id.string, "HWP0001") =3D 0);
 			kfree(info);
 			if (match) {

