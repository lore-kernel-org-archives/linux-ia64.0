From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 11 Jun 2004 02:02:40 +0000
Subject: Re: wait4 causes segfault in i386 chroot
Message-Id: <20040611020240.GA13244@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040610051605.GA21936@cse.unsw.EDU.AU>
In-Reply-To: <20040610051605.GA21936@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 10, 2004 at 12:08:26PM -0700, Arun Sharma wrote:
> On 6/9/2004 10:16 PM, Ian Wienand wrote:
>=20
> >I've tracked it down to doing a wait/waitpid/wait4 (they all end up in
> >wait4) in a sigchld signal handler.  If I do a minimal test case where
> >I catch the sigchld and wait, once the call returns it segfaults as in
> >this trace (gdb can't seem to give a good backtrace).
> >
>=20
> I recall seeing this problem earlier. But I'm unable to reproduce it now.=
 I=20
> tried with 2.4.x and 2.6.6. Will try 2.6.7-rc3 later today. What was your=
=20
> glibc version ?

Hi,

I can replicate it with 2.6.6, so I guess we must have different libcs :(=
=20
The libc is 2.3.2.ds1-13 from Debian unstable.

With this in mind, I ran in the chroot with
LD_LIBRARY_PATH=3D/usr/lib/debug and to my surprise things seemed to
work.  Run it again with LD_LIBRARY_PATH=3D/usr/lib/debug/lib/tls (or
indeed just leave the default path) and it segfaults.=20

A guess : the only major difference with the optimised libraries is
they enable __thread which has the effect of putting errno in the TLS
area (sysdeps/unix/sysv/linux/i386).  TLS uses the %gs register to get
at the thread local data.  Now for some reason the gs register gets
trashed somewhere along the way, say in a signal handler, it's
possible that you'd get a segfault?  Anyone got any other ideas (cc:
debian-glibc@lists.debian.org in case they do).

-i

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAyRLAWDlSU/gp6ecRAl0sAKDcdOIwi4bPIeR3vjjMihJrv/qOrwCgzZ5y
Ud/vyv/BlNFVUsIBAt9mw3A=
=3VZ1
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--
