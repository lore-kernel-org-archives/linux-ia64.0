From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 06 Sep 2004 02:11:30 +0000
Subject: Re: [PATCH] fix CONFIG_DISCONTIGMEM and CONFIG_VIRTUAL_MEMMAP
Message-Id: <20040906021129.GA17625@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
List-Id: <linux-ia64.vger.kernel.org>
References: <200409050833.46503.jbarnes@engr.sgi.com>
In-Reply-To: <200409050833.46503.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 05, 2004 at 08:33:46AM -0700, Jesse Barnes wrote:
> Looks like the patch that fixed Ian's problem introduced an ugly warning.=
 =20
> Maybe we could just switch to requiring CONFIG_DISCONTIGMEM and=20
> CONFIG_VIRTUAL_MEMMAP for ia64 in general?  That would let us kill a lot =
of=20
> code and only have one code path, etc.  Benchmarks have shown that the=20
> overhead of CONFIG_DISCONTIGMEM is very difficult to measure (if you look=
 at=20
> the code, the only added overhead in any fast path is an additional point=
er=20
> dereference in alloc_pages).  CONFIG_VIRTUAL_MEMMAP is a little more=20
> expensive iirc, but still difficult to measure.

Guilty as charged, I only checked it on my machine.

If performance isn't an issue [*], for mine, combining the the two
seems like the most logical thing to do to me, as it is only causing
confusion with the two being apart.  Setting myself the simple goal of
running with discontig and virtual mem map without NUMA, the diffstat
of the patch looks like

 Makefile                     |    2
 arch/ia64/Kconfig            |    4
 arch/ia64/mm/discontig.c     |  180 ++------------------------------------=
-----
 arch/ia64/mm/numa.c          |  171 ++++++++++++++++++++++++++++++++++++++=
++
 include/asm-ia64/meminit.h   |    2
 include/asm-ia64/processor.h |    4
 6 files changed, 189 insertions(+), 174 deletions(-)

Most of that is copy-paste moving of a few things from discontig.c to
in numa.c.  My point is that it probably isn't too hard (but I guess
that's probably not news).

-i

[*] I'm always happy to run any benchmarks you want on the machines we
have.

--IJpNTDwzlM2Ie8A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBO8dRWDlSU/gp6ecRAsPVAJ4664q7uF4H0BunmnblTrT9pEu29ACgqBpG
taYD8mBPawRPfNBAT2A6enY=
=L6JQ
-----END PGP SIGNATURE-----

--IJpNTDwzlM2Ie8A6--
