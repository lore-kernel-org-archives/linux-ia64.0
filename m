From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 16 Nov 2005 22:41:33 +0000
Subject: Re: [PATCH] RFC : Page table macros
Message-Id: <20051116224133.GI2440@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="RYJh/3oyKhIjGcML"
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--RYJh/3oyKhIjGcML
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 16, 2005 at 02:29:27PM -0800, Chen, Kenneth W wrote:
> It may make sense for the pte level, but I don't see any value being added
> at pgd, pud, and pmd level.  Nobody knows on top of their head what is
> PMD_ENTRY_BITS.  One can grep, but that's my point, why should someone do
> the extra grep in order to find out that size of a pointer is 3?  One
> already know.

Well, therein lies my point.  Is it the size of a pointer or is it the
size of a pte/middle/uppper/global directory entry?  Yes, it is just
terminology; but if you're talking about "size of a blah directory
entry" and you have that size defined in pgtable.h, I think it is
better to use that definition in your assembly rather than refer to
it in some way that generates the same code but has slightly different
meaning.

The 4 level page table case where things have been left as
(4*PAGE_SHIFT - 9) I think shows that abstracting to think about
things as entries rather than as pointers is useful.

-i

--RYJh/3oyKhIjGcML
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDe7WdWDlSU/gp6ecRAuvOAJ9s++/34kFEkRgyYy14zPuzYVGHDQCfZBzz
QAr2auxquwVhXfNxgEUlsr8=
=iCut
-----END PGP SIGNATURE-----

--RYJh/3oyKhIjGcML--
