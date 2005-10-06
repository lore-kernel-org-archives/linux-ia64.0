From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 06 Oct 2005 01:02:58 +0000
Subject: Re: [Fwd: Weird ia64 problem]
Message-Id: <20051006010258.GL1394@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="U3s59FfKcByyGl+j"
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
To: linux-ia64@vger.kernel.org


--U3s59FfKcByyGl+j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 05, 2005 at 04:40:24PM -0700, Luck, Tony wrote:
> Hmmph.  According to strace, there are no system calls resulting from
> the fpathconf() call.  How does it come up with the magic 4096 value?

Looks like it's built with the value of PIPE_BUF from
include/linux/limits.h

Through a binary search, on my system (16K pages) with the original
test program, setting pipe_buf to 10923 fails with EAGAIN, but add one
more byte (10924) and it works.  I can't immediately see how that
number relates to anything.

-i

--U3s59FfKcByyGl+j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDRHfCWDlSU/gp6ecRAs6fAJ43t0+Rau+iB7uDz077zkX17iyYWQCgiRZG
47Vq8IgVdxiNNwkGbJ+Rdcs=
=3T5f
-----END PGP SIGNATURE-----

--U3s59FfKcByyGl+j--
