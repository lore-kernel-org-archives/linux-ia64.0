From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Sep 2001 15:45:38 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805250@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

|> Here is a long-awaited kernel update which brings us in sync with
|> 2.4.10.  As usual, it's available at
|> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:
|>=20
|> 	linux-2.4.10-ia64-010924.diff*

This patch is needed to get the DRM code to compile:

--- linux/drivers/char/drm/drmP.h	2001/09/25 12:19:14	1.1
+++ linux/drivers/char/drm/drmP.h	2001/09/25 12:19:24
@@ -366,10 +366,10 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof =3D 1; return len - offset; }
=20
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map)						\
+#define DRM_IOREMAP(map, dev)						\
 	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size, (dev) )
=20
-#define DRM_IOREMAPFREE(map)						\
+#define DRM_IOREMAPFREE(map, dev)					\
 	do {								\
 		if ( (map)->handle && (map)->size )			\
 			DRM(ioremapfree)( (map)->handle, (map)->size, (dev) );	\

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

