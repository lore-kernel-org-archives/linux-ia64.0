From: Andreas Schwab <schwab@suse.de>
Date: Fri, 24 May 2002 13:38:38 +0000
Subject: [Linux-ia64] Off-by-one in show_cpuinfo
Message-Id: <marc-linux-ia64-105590701905595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This fixes an off-by-one in show_cpuinfo (to get the NUL copied too):

--- linux/arch/ia64/kernel/setup.c.~1~	2002-05-19 06:37:30.000000000 +0200
+++ linux/arch/ia64/kernel/setup.c	2002-05-24 15:36:09.000000000 +0200
@@ -393,7 +393,7 @@ show_cpuinfo (struct seq_file *m, void *
=20
 	switch (c->family) {
 	      case 0x07:	memcpy(family, "Itanium", 8); break;
-	      case 0x1f:	memcpy(family, "Itanium 2", 9); break;
+	      case 0x1f:	memcpy(family, "Itanium 2", 10); break;
 	      default:		sprintf(family, "%u", c->family); break;
 	}
=20

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

