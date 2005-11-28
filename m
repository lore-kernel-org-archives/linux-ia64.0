From: Andreas Schwab <schwab@suse.de>
Date: Mon, 28 Nov 2005 09:44:25 +0000
Subject: Re: initrd_size inflation breaks initramfs
Message-Id: <jek6etcdja.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1133159027.6062.98.camel@localhost>
In-Reply-To: <1133159027.6062.98.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

dann frazier <dannf@hp.com> writes:

> My guess is that this is a bug in elilo.

Try this patch:

--- initrd.c
+++ initrd.c
@@ -94,6 +94,9 @@
=20
 	initrd->start_addr =3D start_addr;
=20
+	/* Clear extra memory since we don't pass the exact size.  */
+	Memset(start_addr + size, 0, (pgcnt << EFI_PAGE_SHIFT) - size);
+
 	return ELILO_LOAD_SUCCESS;
=20
 error:

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
