From: Andreas Schwab <schwab@suse.de>
Date: Fri, 06 Apr 2001 15:24:19 +0000
Subject: Re: [Linux-ia64] New gnu-efi package and new boot loader available
Message-Id: <marc-linux-ia64-105590693005378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005375@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005375@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Stephane Eranian <eranian@frankl.hpl.hp.com> writes:

|> Hi,
|>=20
|> I have uploaded to the HPLabs FTP site a new version of the gnu-efi=20
|> package.  It is available at:
|> =09
|> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-2.0.tar.gz

Another patch to improve the usefullness of the config file:

--- elilo/config.c
+++ elilo/config.c	2001/04/06 15:02:19
@@ -46,6 +46,7 @@
 } boot_image_t;
=20
 boot_image_t *image_head, *default_image;
+static CHAR16 *root;
=20
 /*
  * XXX: needs to be cleaned up seriously
@@ -167,12 +168,12 @@
 		} else if (strncmpa(p1, "vga", 3) =3D 0) {
 			/* FIXME: I think we can actually do this */
 		} else if (strncmpa(p1, "timeout", 7) =3D 0) {
-			//timeout =3D Atoi(aToU(p2));
+			elilo_opt.timeout =3D Atoi(aToU(p2));
 		} else if (strncmpa(p1, "root", 4) =3D 0) {
 			if (image)
 				image->root =3D StrDuplicate(aToU(p2));
-			//else
-				//root =3D StrDuplicate(aToU(p2));
+			else
+				root =3D StrDuplicate(aToU(p2));
 		} else if (strncmpa(p1, "initrd",6) =3D 0) {
 			if (image)
 				image->initrd =3D StrDuplicate(aToU(p2));
@@ -271,16 +272,16 @@
=20
 	options[0] =3D 0;
=20
-	if (img->root) {
+	if (img->root || root) {
 		StrCat(options, W2U(L"root=3D"));
-		StrCat(options, img->root);
+		StrCat(options, img->root ? img->root : root);
 	}
 	/* XXX: check max length */
 	if (img->options) {
 		StrCat(options, W2U(L" "));
 		StrCat(options, img->options);
 	}
-	if (img->readonly) {
+	if (img->readonly !=3D -1 ? img->readonly : elilo_opt.readonly) {
 		StrCat(options, W2U(L" ro"));
 	}
 	if (img->initrd) StrCpy(initrd, img->initrd);

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

