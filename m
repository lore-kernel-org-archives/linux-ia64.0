From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Apr 2004 16:49:45 +0000
Subject: Missing overflow check in mmap
Message-Id: <jek70u74k6.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Calling mmap with len =3D -1 was silently accepted.

Andreas.

--- linux-2.6.5/arch/ia64/kernel/sys_ia64.c.~1~	2004-04-04 05:37:23.0000000=
00 +0200
+++ linux-2.6.5/arch/ia64/kernel/sys_ia64.c	2004-04-05 18:16:24.424002264 +=
0200
@@ -201,10 +201,16 @@ do_mmap2 (unsigned long addr, unsigned l
 	 * A zero mmap always succeeds in Linux, independent of whether or not the
 	 * remaining arguments are valid.
 	 */
-	len =3D PAGE_ALIGN(len);
 	if (len =3D 0)
 		goto out;
=20
+	/* Careful about overflows.. */
+	len =3D PAGE_ALIGN(len);
+	if (!len || len > TASK_SIZE) {
+		addr =3D -EINVAL;
+		goto out;
+	}
+
 	/*
 	 * Don't permit mappings into unmapped space, the virtual page table of a=
 region,
 	 * or across a region boundary.  Note: RGN_MAP_LIMIT is equal to 2^n-PAGE=
_SIZE

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
