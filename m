From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 16 Nov 2005 23:19:14 +0000
Subject: Re: [PATCH] RFC : Page table macros
Message-Id: <20051116231914.GJ2440@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="gDGSpKKIBgtShtf+"
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--gDGSpKKIBgtShtf+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 16, 2005 at 02:53:14PM -0800, Chen, Kenneth W wrote:
> Ian Wienand wrote on Wednesday, November 16, 2005 2:42 PM
> > Well, therein lies my point.  Is it the size of a pointer or is it the
> > size of a pte/middle/uppper/global directory entry?
> 
> I think you are mixing up with pte_t versus {pmd_t, pud_t, pgd_t}.
> Or maybe we simply don't understand each other :-(

This type of conversation is always hard over email!

The very way those entries are defined implies a level of abstraction.
For example  

typedef struct { unsigned long pmd; } pmd_t;
# define pmd_val(x)     ((x).pmd)

Now it's conceivable (if unlikely) that you might make a pmd have
another field.  Nothing should care because if it gets the value of
the pmd via the pmd_val macro, which returns the right thing.
However, you'd have to manually go through ivt.S to replace all the
(PAGE_SHIFT-3)'s.

So what we are saying in ivt.S is not really "size of a pointer" but
"size of a pmd entry".  They happen to be the same thing, but why
leave the definitions in two places at once?

Anyway, I'm not all that fussed about the ivt.S changes, as you say it
is very low level anyway.  But the assumptions in pgtable.h have
caused me grief before so my main argument would be for something like
them.

-i

--gDGSpKKIBgtShtf+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDe75yWDlSU/gp6ecRAoYIAJ97+ur1/qZe9h0dYKBJHcTNKhxLngCdHOgK
MUpNjcwICpls0zJ1LWLzz58=
=HlO+
-----END PGP SIGNATURE-----

--gDGSpKKIBgtShtf+--
