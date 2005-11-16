From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 16 Nov 2005 18:31:16 +0000
Subject: RE: [PATCH] RFC : Page table macros
Message-Id: <200511161831.jAGIVGg12799@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051116050037.GF2440@cse.unsw.EDU.AU>
In-Reply-To: <20051116050037.GF2440@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote on Wednesday, November 16, 2005 4:42 AM
> On Tue, Nov 15, 2005 at 10:09:46PM -0800, Chen, Kenneth W wrote:
> > Ian Wienand wrote on Tuesday, November 15, 2005 9:01 PM
> > > Please find below a patch to make some page table modifications
> > > similar to something I posted earlier before the 4 level stuff.
> > 
> > I'm not so sure about the change in ivt.S.  It makes the code a
> > lot harder to read.  After all, the asm code in ivt.S is very
> > low level and deal with all the low level detail anyway.  You
> > aren't going to get away with more macros.
> 
> I disagree.  I think we could make significant improvements in
> readability.  I don't think this patch is there, but it at
> least starts the ball rolling.


Besides the readability issue I have, I have a bigger issue with the
patch that it introduces *buggy* code. For example:

-(p7)	dep r17=r17,r19,(PAGE_SHIFT-3),3	// put region number bits in place
+(p7)	dep r17=r17,r19,PGD_INDEX_BITS,PGD_ENTRY_BITS	// put region number bits in place

The fact that we take 3 bits out of source is not because pgd entry
is 3 bit long, but rather, region bits is 3!  The fact that we deposit
into bit position 11 is because we put it as the most significant bits
of the pgd index, not because pgd index has 11 bits.

Put aside the buggy code argument, let's look at the macro: pgd_offset(),
pud_offset, and pmd_offset() are all pointer calculation, everyone knows
what pointer size is (if you don't, you are in trouble and shouldn't be
mucking around with ivt.S :-)  what do you mean by defining:

+#define PMD_ENTRY_BITS	3
+#define PGD_ENTRY_BITS	3

Size of pointer?  Then why another indirection? It simply can't be more
explicit to know that size of pointer is 3 bit and such constant is used
in the index calculation.  Perhaps what you should do is to add a
comments in the beginning of vhpt_miss handler and say that we are pretty
much doing:

        pgd = pgd_offset(mm, addr);
        if (pgd_present(*pgd)) {
                pud = pud_offset(pgd, addr);
                if (pud_present(*pud)) {
                        pmd = pmd_offset(pud, addr);
                        if (pmd_present(*pmd))
                                pte = pte_offset_map(pmd, addr);
                }
        }

and be done with it.

Here is another example:

-	cmp.eq p6,p7=5,r17			// is IFA pointing into to region 5?
+	cmp.eq p6,p7=5,r17			// is faulting address in region 5?

What do you mean by "faulting address"?  Vhpt_miss handler handles two
faulting addresses, tlb for ifa and the pte pointer.  This change muddy
the confusion while the original comments is very explicit about which
one it is looking at.

- Ken

