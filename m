From: Andreas Schwab <schwab@suse.de>
Date: Wed, 14 May 2003 08:31:24 +0000
Subject: Re: [Linux-ia64] libc umount and umount2 can't both be right
Message-Id: <marc-linux-ia64-105590723705783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Ian Wienand <ianw@gelato.unsw.edu.au> writes:

|> [originally cc: libc-alpha but screwed up the cc line so it was rejected=
 here]
|>=20
|> >On Tue, May 13, 2003 at 04:06:41PM -0400, MONTGOMERY,BOB (HP-FtCollins,=
ex1) wrote:
|> > In libc, umount and umount2 are the same code.  They both use
|> > syscall number 1044 without introducing a call layer.=20
|>=20
|> looks like a typo in libc to me
|>=20
|> -i
|> ianw@gelato.unsw.edu.au
|> http://www.gelato.unsw.edu.au
|>=20
|> --- libc/sysdeps/unix/sysv/linux/ia64/syscalls.list.old 2003-05-14 09:10=
:04.000000000 +1000
|> +++ libc/sysdeps/unix/sysv/linux/ia64/syscalls.list     2003-05-14 09:09=
:40.000000000 +1000
|> @@ -1,6 +1,6 @@
|>  # File name    Caller  Syscall name    # args  Strong name     Weak nam=
es
|>  =20
|> -umount2                -       umount          2       __umount2       =
umount2
|> +umount2                -       umount2         2       __umount2       =
umount2

Except there is no umount2 syscall on ia64.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

