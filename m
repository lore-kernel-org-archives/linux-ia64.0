From: Andreas Schwab <schwab@suse.de>
Date: Fri, 30 Jun 2000 12:24:35 +0000
Subject: [Linux-ia64] ELI uninitialized variable bug
Message-Id: <marc-linux-ia64-105590678205185@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This patch fixes an uninitialized variable in eli-0.4.0, when no initrd
was requested.

--- eli-0.4.0/eli.c
+++ eli-0.4.0/eli.c	2000/06/30 10:06:36
@@ -1242,6 +1242,9 @@
 		case EFI_LOAD_ERROR:
 			goto free_kernel_image;
 		}
+	} else {
+		initrd.start_addr =3D 0;
+		initrd.pages =3D 0;
 	}
=20
 	/* Must free the ACPI before creating the boot params so the */

Andres.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg


