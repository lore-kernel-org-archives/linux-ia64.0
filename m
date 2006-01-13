From: Andreas Schwab <schwab@suse.de>
Date: Fri, 13 Jan 2006 22:46:38 +0000
Subject: Re: build broken for ia64 simserial.c
Message-Id: <je4q4721bl.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F056BA512@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F056BA512@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> Alan,
>
> TTY layer buffering revamp broke ia64.
>
>   CC      arch/ia64/hp/sim/simserial.o
> arch/ia64/hp/sim/simserial.c: In function `receive_chars':
> arch/ia64/hp/sim/simserial.c:170: error: structure has no member named `f=
lip'
> arch/ia64/hp/sim/simserial.c:172: error: structure has no member named `f=
lip'
> arch/ia64/hp/sim/simserial.c:174: error: structure has no member named `f=
lip'
> arch/ia64/hp/sim/simserial.c:176: error: structure has no member named `f=
lip'
> arch/ia64/hp/sim/simserial.c:177: error: structure has no member named `f=
lip'
> arch/ia64/hp/sim/simserial.c:178: error: structure has no member named `f=
lip'
> make[1]: *** [arch/ia64/hp/sim/simserial.o] Error 1
>
> Any quick hints on the fix?

This should work (untested):

--- linux/arch/ia64/hp/sim/simserial.c.~1~	2006-01-13 16:02:17.213612854 +0=
100
+++ linux/arch/ia64/hp/sim/simserial.c	2006-01-13 23:44:03.594619721 +0100
@@ -167,15 +167,9 @@ static  void receive_chars(struct tty_st
 			}
 		}
 		seen_esc =3D 0;
-		if (tty->flip.count >=3D TTY_FLIPBUF_SIZE) break;
=20
-		*tty->flip.char_buf_ptr =3D ch;
-
-		*tty->flip.flag_buf_ptr =3D 0;
-
-		tty->flip.flag_buf_ptr++;
-		tty->flip.char_buf_ptr++;
-		tty->flip.count++;
+		if (tty_insert_flip_char(tty, ch, TTY_NORMAL) =3D 0)
+			break;
 	}
 	tty_flip_buffer_push(tty);
 }

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
