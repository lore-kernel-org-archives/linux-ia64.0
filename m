From: Andreas Schwab <schwab@suse.de>
Date: Wed, 16 May 2001 10:33:39 +0000
Subject: Re: [Linux-ia64] Announcing efibootmgr-0.2.0
Message-Id: <marc-linux-ia64-105590693005588@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matt_Domsch@Dell.com writes:

|> Announcing efibootmgr-0.2.0, a Linux user-space application which intera=
cts
|> with the EFI Boot Manager.  It may be downloaded from
|> http://domsch.com/linux/ia64/efibootmgr-0.2.0.tar.gz.

Here is another patch that fixes a crash.

--- efibootmgr-0.2.0/src/lib/efi.c.~1~	Wed May 16 12:16:03 2001
+++ efibootmgr-0.2.0/src/lib/efi.c	Wed May 16 12:31:02 2001
@@ -88,7 +88,6 @@
 efi_status_t
 write_variable(efi_variable_t *var)
 {
-	char *newname;
 	int fd;
 	size_t writesize;
 	char buffer[PATH_MAX];
@@ -99,7 +98,6 @@
 	if (fd =3D=3D -1) {
 		sprintf(buffer, "write_variable():open(%s)", name);
 		perror(buffer);
-		free(newname);
 		return EFI_INVALID_PARAMETER;
 	}
 	writesize =3D write(fd, var, sizeof(*var));
@@ -108,7 +106,6 @@
 		sprintf(buffer, "write_variable():write(%s)", name);
 		perror(buffer);
 		dump_raw_data(var, sizeof(*var));
-		free(newname);
 #endif
 		close(fd);
 		return EFI_INVALID_PARAMETER;

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

