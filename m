From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 17 Mar 2005 23:17:48 +0000
Subject: RE: Recent fix for pgd_addr_end
Message-Id: <16954.4124.220494.355677@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> In the recent fix to include/asm-ia64/pgtable.,h, the coode now
>> sign-extends the top of the pgdindex into the reserved region.
>> 
>> Are you sure this is correct?  Mosberger+Eranian says that these
>> bits must be zero: page 159, end of first paragraph, `What is
>> unusual is that the global-directory index is split into a 7-bit
>> low part (pgdi) and a 3 bit high part (pgdh) that covers bits 22 to
>> 39 and 61 to 63 respectively.  Bits 40 to 60 are unused and must be
>> 0.' (Of course the bit numbers here are for 8k pages, and have to
>> be adjusted).


Tony> I don't have the book handy, but the relevent chapter is online.
Tony> I see it saying:
Tony> http://www.phptr.com/articles/article.asp?p)961&seqNum=2

Tony> "The unimplemented portion of the virtual address consists of
Tony> bits IMPL_VA_MSB + 1 through 60. Even though they are marked as
Tony> unimplemented, the architecture requires that the value in these
Tony> bits match the value in bit IMPL_VA_MSB. In other words, the
Tony> unimplemented bits must correspond to the sign-extended value of
Tony> the lower portion of the virtual address.  This restriction has
Tony> been put in place to ensure that software does not abuse
Tony> unimplemented bits for purposes such as type tag
Tony> bits. Otherwise, such software might break when running on a
Tony> machine that implements a larger number of virtual address
Tony> bits."

Tony> Figure 4.13 just below this text shows the hole in the middle of
Tony> the region that this creates.

That's the IA64 architecture defined unimplemented bits, which are
sign extended from the most significant implemented bit other than the
region ID in the virtual address.  Go onto the next page:

       http://www.phptr.com/articles/article.asp?p)961&seqNum=3

and look for figure 4.21 and its commentary.



-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
