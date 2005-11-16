From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 16 Nov 2005 22:29:27 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <200511162229.jAGMTRg29886@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand wrote on Wednesday, November 16, 2005 1:03 PM
> On Wed, Nov 16, 2005 at 10:31:16AM -0800, Chen, Kenneth W wrote:
> > Besides the readability issue I have, I have a bigger issue with the
> > patch that it introduces *buggy* code. For example:
> > 
> > -(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
> > +(p7)	dep r17=r17,r19,PGD_INDEX_BITS,PGD_ENTRY_BITS	// put region number bits in place
> 
> Thanks; I didn't mean to put that PGD_ENTRY_BITS there but maybe it
> illustrates how being more descriptive might have helped?

I don't see that.  The comment is already very descriptive. If someone
doesn't know region bits is 3, he shouldn't be looking at vhpt_miss
handler at all.


> > Put aside the buggy code argument, let's look at the macro: pgd_offset(),
> > pud_offset, and pmd_offset() are all pointer calculation, everyone knows
> > what pointer size is (if you don't, you are in trouble and shouldn't be
> > mucking around with ivt.S :-)  what do you mean by defining:
> > 
> > +#define PMD_ENTRY_BITS	3
> > +#define PGD_ENTRY_BITS	3
> > 
> > Size of pointer?  Then why another indirection? It simply can't be more
> > explicit to know that size of pointer is 3 bit and such constant is used
> > in the index calculation.
> 
> Well, because the size of a PTE might not always be 8, and I figured
> if you do it for one level you might as well do all levels with the
> same scheme.  This way all the calculations in pgtable.h are done in a
> consistent manner.

It may make sense for the pte level, but I don't see any value being added
at pgd, pud, and pmd level.  Nobody knows on top of their head what is
PMD_ENTRY_BITS.  One can grep, but that's my point, why should someone do
the extra grep in order to find out that size of a pointer is 3?  One
already know.


> Indeed, although I don't think it's too hard to understand the whole
> gist of the code, but rather the tiny details which I was trying to be
> more explicit with.

You can polish the comment, I think that is all very welcome.  What my
objection is the argument of "more macro equates to better readability".

- Ken

