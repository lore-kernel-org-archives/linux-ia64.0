From: Andreas Schwab <schwab@suse.de>
Date: Wed, 14 May 2003 18:55:56 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705806@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

|> On Wed, May 14, 2003 at 10:32:14AM -0700, David Mosberger wrote:
|> >   Matthew> Yuck.  The right way to do this is
|> >   Matthew> read_trylock(&tasklist_lock); The observant will have
|> >   Matthew> noted:
|> >=20
|> >   Matthew> /* Where's read_trylock? */
|> >=20
|> >   Matthew> in include/linux/spinlock.h but that doen't justify _not
|> >   Matthew> writing it_ when you need it.
|> >=20
|> > You want to send me a patch? ;-)
|>=20
|> Yes, I'd love to ;-)  I just need to fix your 2.5.69 patch so it'll comp=
ile :-P
|> $ find -type f |xargs grep compat_sys_setaffinity
|> ./arch/ia64/ia32/ia32_entry.S:  data8 compat_sys_setaffinity
|> Binary file ./arch/ia64/ia32/ia32_entry.o matches
|> Binary file ./arch/ia64/ia32/built-in.o matches

--- linux-2.5.69/arch/ia64/ia32/ia32_entry.S.~1~	2003-05-14 12:14:33.000000=
000 +0200
+++ linux-2.5.69/arch/ia64/ia32/ia32_entry.S	2003-05-14 12:57:22.000000000 =
+0200
@@ -439,8 +439,8 @@ ia32_syscall_table:
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 compat_sys_futex	/* 240 */
-	data8 compat_sys_setaffinity
-	data8 compat_sys_getaffinity
+	data8 compat_sys_sched_setaffinity
+	data8 compat_sys_sched_getaffinity
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall	/* 245 */

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

