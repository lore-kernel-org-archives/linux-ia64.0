From: Andreas Schwab <schwab@suse.de>
Date: Tue, 02 Mar 2004 23:49:20 +0000
Subject: Fix staircase effect on Altix serial console.
Message-Id: <je1xoa7qtb.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Serial console output on Altix didn't convert NL to CRNL.

Andreas.

--- linux-2.6.3/drivers/char/sn_serial.c.~1~	2004-03-02 16:41:09.000000000 =
+0100
+++ linux-2.6.3/drivers/char/sn_serial.c	2004-03-02 22:51:09.049180364 +0100
@@ -984,6 +984,7 @@ static void
 sn_sal_console_write(struct console *co, const char *s, unsigned count)
 {
 	unsigned long flags;
+	const char *s1;
=20
 	BUG_ON(!sn_sal_is_asynch);
=20
@@ -991,15 +992,36 @@ sn_sal_console_write(struct console *co,
 	 * oops, kdb, panic, etc.  make sure they get it. */
 	if (spin_is_locked(&sn_sal_lock)) {
 		synch_flush_xmit();
+		/* Output '\r' before each '\n' */
+		while ((s1 =3D memchr(s, '\n', count)) !=3D NULL) {
+			sn_func->sal_puts(s, s1 - s);
+			sn_func->sal_puts("\r\n", 2);
+			count -=3D s1 + 1 - s;
+			s =3D s1 + 1;
+		}
 		sn_func->sal_puts(s, count);
 	}
 	else if (in_interrupt()) {
 		spin_lock_irqsave(&sn_sal_lock, flags);
 		synch_flush_xmit();
 		spin_unlock_irqrestore(&sn_sal_lock, flags);
+		/* Output '\r' before each '\n' */
+		while ((s1 =3D memchr(s, '\n', count)) !=3D NULL) {
+			sn_func->sal_puts(s, s1 - s);
+			sn_func->sal_puts("\r\n", 2);
+			count -=3D s1 + 1 - s;
+			s =3D s1 + 1;
+		}
 		sn_func->sal_puts(s, count);
 	}
 	else
+		/* Output '\r' before each '\n' */
+		while ((s1 =3D memchr(s, '\n', count)) !=3D NULL) {
+			sn_sal_write(NULL, 0, s, s1 - s);
+			sn_sal_write(NULL, 0, "\r\n", 2);
+			count -=3D s1 + 1 - s;
+			s =3D s1 + 1;
+		}
 		sn_sal_write(NULL, 0, s, count);
 }
=20

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
