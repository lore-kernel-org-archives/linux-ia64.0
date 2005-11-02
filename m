From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 02 Nov 2005 22:26:12 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051102222612.GK11202@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="JbKQpFqZXJ2T76Sg"
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
To: linux-ia64@vger.kernel.org


--JbKQpFqZXJ2T76Sg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 02, 2005 at 11:16:11AM -0600, Robin Holt wrote:
> I think I will hold off on doing this for now.  I think it is better done
> as a seperate patch.  I will happily try to tackle this once the direction
> of 4-level PTDs is set, but until then, I think I want to skip this.

Ok, cool.  I'll try again later (once I've finished fixing all our
patches to account for 4 levels ;).

I must admit to be a bit perplexed however.  I would have thought that
a customer who just spent (what I assume is a lot of) money on a
machine to map huge areas of contiguous memory would really want to
evaluate the probable benefits of larger pages, despite what Redhat
ships.  I'm probably just extremley naive as to what customers really
want, however.

-i

--JbKQpFqZXJ2T76Sg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDaT0EWDlSU/gp6ecRAqRZAKDYlW8g7fNhp8CaEdrwxbsk3wnRQgCgoAu2
7ddxTHldKmlSmYaZft5Lz1o=
=Qcjp
-----END PGP SIGNATURE-----

--JbKQpFqZXJ2T76Sg--
