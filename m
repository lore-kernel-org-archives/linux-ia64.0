From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 01 May 2006 12:03:04 +0000
Subject: Re: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <20060501120304.GA18045@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
To: linux-ia64@vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 01, 2006 at 04:47:47AM -0500, Robin Holt wrote:
> Isn't the right answer here to have the simulator simulate the actual
> hardware and have the setup initilize itv to a correct value?

Well, as for actual hardware, I read a bit more about it and in SAL
3.2.4 ITV isn't mentioned, and so I guess the initial value is
platform dependent.  Clearly hardware sets it masked, else the code
wouldn't work.

But I don't think this code need bother checking?  It runs on the boot
processor before anything else is happening, and the interrupt is
correctly setup (disabled) when it needs to be for this CPU and others
in cpu_init().

-i

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEVfj4WDlSU/gp6ecRAhzwAJ9CezQlwEU3GpXVJCgDGMrxyV5i7gCgi9sV
JD0hXkFVFds+J8ECZuZNolY=
=oV69
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
