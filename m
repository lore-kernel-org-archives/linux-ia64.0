From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Mar 2003 13:41:01 +0000
Subject: [Linux-ia64] Unwinder bug
Message-Id: <marc-linux-ia64-105590723705308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I've found this by inspecting the code: pt_regs_off returns an offset into
struct pt_regs.  Relative to latest bk, 2.5 has the same bug.

Andreas.

--- linux-ia64-2.4/arch/ia64/kernel/unwind.c.~1~	2003-03-25 13:38:21.000000=
000 +0100
+++ linux-ia64-2.4/arch/ia64/kernel/unwind.c	2003-03-25 13:49:15.000000000 =
+0100
@@ -324,7 +324,7 @@ unw_access_gr (struct unw_frame_info *in
 		} else {
 			/* access a scratch register */
 			pt =3D get_scratch_regs(info);
-			addr =3D (unsigned long *) (pt + pt_regs_off(regnum));
+			addr =3D (unsigned long *) ((unsigned long)pt + pt_regs_off(regnum));
 			if (info->pri_unat_loc)
 				nat_addr =3D info->pri_unat_loc;
 			else

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

