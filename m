From: Arseny Maslennikov <ar@cs.msu.ru>
Date: Sun, 06 Feb 2022 22:44:05 +0000
Subject: Re: [PATCH v2 3/3] vstatus: Display an informational message when the VSTATUS character is pressed o
Message-Id: <YgBPNYhs/H0DwePH@cello>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="svn0gnZfWDGyJk09"
List-Id: <linux-ia64.vger.kernel.org>
References: <20220206154856.2355838-1-walt@drummond.us>
 <20220206154856.2355838-4-walt@drummond.us>
 <YgA8uIVSX5WSC6Wr@cello>
In-Reply-To: <YgA8uIVSX5WSC6Wr@cello>
To: Walt Drummond <walt@drummond.us>
Cc: agordeev@linux.ibm.com, arnd@arndb.de, benh@kernel.crashing.org, borntraeger@de.ibm.com, chris@zankel.net, davem@davemloft.net, gregkh@linuxfoundation.org, hca@linux.ibm.com, deller@gmx.de, ink@jurassic.park.msu.ru, James.Bottomley@hansenpartnership.com, jirislaby@kernel.org, mattst88@gmail.com, jcmvbkbc@gmail.com, mpe@ellerman.id.au, paulus@samba.org, rth@twiddle.net, dalias@libc.org, tsbogend@alpha.franken.de, gor@linux.ibm.com, ysato@users.osdn.me, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, sparclinux@vger.kernel.org


--svn0gnZfWDGyJk09
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 07, 2022 at 12:25:21AM +0300, Arseny Maslennikov wrote:
> On Sun, Feb 06, 2022 at 07:48:54AM -0800, Walt Drummond wrote:
> > @@ -2430,6 +2459,11 @@ static int n_tty_ioctl(struct tty_struct *tty, s=
truct file *file,
> >  			retval =3D read_cnt(ldata);
> >  		up_write(&tty->termios_rwsem);
> >  		return put_user(retval, (unsigned int __user *) arg);
> > +	case TIOCSTAT:
>=20
> Perhaps we want to guard this (example pseudocode follows):
>=20
> 		if (*our ldisc is not n_tty*)
> 			return an error like -ENOTTY;
>=20
> ...since kerninfo is useless for non-UI ttys, e. g. serial device
> drivers, and this ioctl could mess them up if this code path can be
> taken. (I have not verified this kind of breakage is possible.) Please
> see the complete rationale below, this paragraph is an illustrational
> note for it.

Oh wait, this *is* n_tty_ioctl(), so the ioctl is n_tty-specific. This
makes the case below even clearer.
I've been clumsy, sorry about that.

> > diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
> > index 6616d4a0d41d..f2f4f48ea502 100644
> > --- a/drivers/tty/tty_io.c
> > +++ b/drivers/tty/tty_io.c
> > @@ -125,7 +125,7 @@ struct ktermios tty_std_termios =3D {	/* for the be=
nefit of tty drivers  */
> >  	.c_oflag =3D OPOST | ONLCR,
> >  	.c_cflag =3D B38400 | CS8 | CREAD | HUPCL,
> >  	.c_lflag =3D ISIG | ICANON | ECHO | ECHOE | ECHOK |
> > -		   ECHOCTL | ECHOKE | IEXTEN,
> > +		   ECHOCTL | ECHOKE | IEXTEN | NOKERNINFO,
>=20
> Does this mean that nokerninfo is on by default? Do we have a reason to
> do that?
>=20
> As of this patch we require icanon and iexten to be set for the message
> to be composed and printed. An experiment shows PTY encapsulation
> programs like openssh turn off both those flags on the tty they run on
> before they take control (contrary to what has been said in LWN), so
> they are unimpacted.
>=20
> The termios(3) page from man-pages states:
>    Raw mode
>        cfmakeraw() sets the terminal to something like the "raw"  mode
>        of  the old Version 7 terminal driver: input is available char=E2=
=80=90
>        acter by character, echoing is disabled, and all  special  pro=E2=
=80=90
>        cessing  of  terminal  input and output characters is disabled.
>        The terminal attributes are set as follows:
>=20
>            termios_p->c_iflag &=3D ~(IGNBRK | BRKINT | PARMRK | ISTRIP
>                            | INLCR | IGNCR | ICRNL | IXON);
>            termios_p->c_oflag &=3D ~OPOST;
>            termios_p->c_lflag &=3D ~(ECHO | ECHONL | ICANON | ISIG | IEXT=
EN);
>            termios_p->c_cflag &=3D ~(CSIZE | PARENB);
>            termios_p->c_cflag |=3D CS8;
>=20
> So any program which uses this API effectively turns off kerninfo as
> implemented here.
>=20
> There are 2 ways n_tty_status() can be called as of this patch: either
> from inside n_tty or via TIOCSTAT. The first path can't be taken on ttys
> whose ldisc is not N_TTY, ...

The second path is OK as well.

> Given all this, is there any other reason to enable nokerninfo (i. e.
> disable status message) by default?

--svn0gnZfWDGyJk09
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE56JD3UKTLEu/ddrm9dQjyAYL01AFAmIATy0ACgkQ9dQjyAYL
01BThhAAyojlvq3x6fFW7k+F5Rtcr5jxVEKrP8xCWEudyGFTFGl/swNMGGOpBxCU
eAd/mhCEXEt8QpI/F0wowD7QpFhpWDzTuXQ/LUUyu1VJURaKeH05zrT6AComAyz4
Y0xowt5LE0NLBUhnhCPckh26xJw+8ThB1C8rEq0FX9YrnGDaFtMhgZ4vIfpxHpe1
G+rTk18gFuNPZ8b6mknle7fgPWDxpnNQ0qs/aA56EAzdVVJcrwaWaw3GSnnvn/gQ
lvW8i/lSyIxF19Df8bsCEk01bEuHebBRck7wnT/PSkh2oP7lDBWJ38lWzHyTiQIU
w0k6/7PzyGdy23T7HCMApyaXSYzX6qHPwFo43nR4k5bYa+74RUBoxckJlv4E/7y/
jCzcbdIFuWhGwK2R6Wjlw/i/awuBIRrIcBTNqz1OGUxyKEj7Oo45BtQoEh1bxAyn
O/IDgY0riOZcB0MdPyUvWlpAvdAhBgxfPVVNDttm5CG/qBt8LLnLB/cYfSW6eUGq
FDGxXTcM02iFrVnzb010DgbV8v8T2ijwVNDkv3QoOk4uz4l+nbwXlKoGcBkT0ipx
RKXSBlAZcf1UOntNvCX0bTW0k2h7lfLiuUFxc/VasYl3rt/1Y6wfBlv7HpqMPt3I
2ER6KCbkih5045twm/xub9qDsnanN6q4ck5lprnO1T4rDPVXvH4=
=jF16
-----END PGP SIGNATURE-----

--svn0gnZfWDGyJk09--
