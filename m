From: Andreas Schwab <schwab@suse.de>
Date: Sun, 25 Jan 2004 19:54:28 +0000
Subject: Fix xbow.c compilation
Message-Id: <jesmi3reh7.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes a conflicting declaration in xbow.c.

--- linux-2.6.1/arch/ia64/sn/io/sn2/xbow.c.~1~	2004-01-25 20:22:21.00000000=
0 +0100
+++ linux-2.6.1/arch/ia64/sn/io/sn2/xbow.c	2004-01-25 20:41:37.000000000 +0=
100
@@ -153,7 +153,7 @@ xbow_attach(vertex_hdl_t conn)
 #if DEBUG && ATTACH_DEBUG
     char		    name[MAXDEVNAME];
 #endif
-    static void xbow_errintr_handler(int, void *, struct pt_regs *);
+    static irqreturn_t xbow_errintr_handler(int, void *, struct pt_regs *);
=20
 =09
 #if DEBUG && ATTACH_DEBUG

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
