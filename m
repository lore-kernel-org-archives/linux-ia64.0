From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 16 Nov 2005 21:03:13 +0000
Subject: Re: [PATCH] RFC : Page table macros
Message-Id: <20051116210313.GA27105@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 16, 2005 at 10:31:16AM -0800, Chen, Kenneth W wrote:
> Besides the readability issue I have, I have a bigger issue with the
> patch that it introduces *buggy* code. For example:
> 
> -(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
> +(p7)	dep r17=r17,r19,PGD_INDEX_BITS,PGD_ENTRY_BITS	// put region number bits in place

Thanks; I didn't mean to put that PGD_ENTRY_BITS there but maybe it
illustrates how being more descriptive might have helped?

> Put aside the buggy code argument, let's look at the macro: pgd_offset(),
> pud_offset, and pmd_offset() are all pointer calculation, everyone knows
> what pointer size is (if you don't, you are in trouble and shouldn't be
> mucking around with ivt.S :-)  what do you mean by defining:
> 
> +#define PMD_ENTRY_BITS	3
> +#define PGD_ENTRY_BITS	3
> 
> Size of pointer?  Then why another indirection? It simply can't be more
> explicit to know that size of pointer is 3 bit and such constant is used
> in the index calculation.

Well, because the size of a PTE might not always be 8, and I figured
if you do it for one level you might as well do all levels with the
same scheme.  This way all the calculations in pgtable.h are done in a
consistent manner.

> Perhaps what you should do is to add a
> comments in the beginning of vhpt_miss handler and say that we are pretty
> much doing:
> 
>         pgd = pgd_offset(mm, addr);
>         if (pgd_present(*pgd)) {
>                 pud = pud_offset(pgd, addr);
>                 if (pud_present(*pud)) {
>                         pmd = pmd_offset(pud, addr);
>                         if (pmd_present(*pmd))
>                                 pte = pte_offset_map(pmd, addr);
>                 }
>         }
> 
> and be done with it.

Indeed, although I don't think it's too hard to understand the whole
gist of the code, but rather the tiny details which I was trying to be
more explicit with.

> Here is another example:
> 
> -	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
> +	cmp.eq p6,p7=5,r17			// is faulting address in region 5?
> 
> What do you mean by "faulting address"?  Vhpt_miss handler handles two
> faulting addresses, tlb for ifa and the pte pointer.  This change muddy
> the confusion while the original comments is very explicit about which
> one it is looking at.

Ok, sure.  That's just how I keep track of it in my head, but you are
right it is less clear.

-i

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDe56RWDlSU/gp6ecRAr5jAJ96aRT+Dw2gAk4sRBaJGESTdjBpbACgstcf
/mA3zD+0HNt0wOdKPcepAZM=
=okg+
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
