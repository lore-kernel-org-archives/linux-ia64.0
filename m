From: Andreas Schwab <schwab@suse.de>
Date: Tue, 22 May 2001 13:38:20 +0000
Subject: Re: [Linux-ia64] Announcing efibootmgr-0.3.1
Message-Id: <marc-linux-ia64-105590693005640@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005626@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005626@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matt_Domsch@Dell.com writes:

|> I really shouldn't try to get stuff out late Friday nights...
|>=20
|> Announcing efibootmgr-0.3.1, a Linux user-space application which
|> interacts with the EFI Boot Manager.  It may be downloaded from
|> http://domsch.com/linux/ia64/efibootmgr-0.3.1.tar.gz.

Here is a patch to fix remove_from_boot_order:

--- efibootmgr.c	2001/05/19 00:05:38	1.1
+++ efibootmgr.c	2001/05/22 13:30:31
@@ -319,7 +319,7 @@
 	uint16_t *new_data, *old_data;
 	int old_i,new_i;
=20
-	read_boot_order(&boot_order);
+	status =3D read_boot_order(&boot_order);
 	if (status !=3D EFI_SUCCESS) return status;
 =09
 	/* If it's empty, yea! */

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

