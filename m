From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 17 Jan 2006 05:39:59 +0000
Subject: Re: First Montecito Reference Manual is now available
Message-Id: <20060117053959.GA11721@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2006 at 08:32:56PM -0800, Luck, Tony wrote:
> The Dual-Core Update to the Intel Itanium 2 Processor 
> Reference Manual is now available publicly

On page 173 it mentions "cycles we run with PCR.sd" set.  What's that?

On page 174 it talks about THREAD_SWITCH_GATED.  What is a gated
thread switch?  Particularly it mentions being gated due to LP, what
is that?

On page 176 it mentions a srlz.i instruction causes a "microtrap" and
an xpn-flush.  What are they?

TLB entries are tagged with the hardware thread.  Is there any
possibility to override this (I mean, even theoretically)?

-i


--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDzIMvWDlSU/gp6ecRAnd/AJ4o+bVje8JRPqu7MDU7N666yB0iDACfWzT8
pJOfiKRzKFqss7nLVMMtQfM=
=aqwO
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--
