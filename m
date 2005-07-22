From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 22 Jul 2005 04:58:08 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050722045808.GC765@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 20, 2005 at 03:31:39PM +1000, Ian Wienand wrote:
> After some investigation I believe this is do with differences between
> the alignment of variables on the stack between gcc 3 and 4 and the
> ski simulator.

For tracking purposes I've put this in the gcc bugzilla

http://gcc.gnu.org/bugzilla/show_bug.cgi?id=22605

-i

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC4HzgWDlSU/gp6ecRAlHGAJ9K/CWzRhamLStvpIsHsUnyYd87ywCgi9U9
U1iuBIp0YW3tDaX1dHARNe4=
=hpB1
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
