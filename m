From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Mar 2005 22:49:32 +0000
Subject: RE: Recent fix for pgd_addr_end
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0319AFE9@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  In the recent fix to include/asm-ia64/pgtable.,h, the coode now
>sign-extends the top of the pgdindex into the reserved region.
>
>Are you sure this is correct?  Mosberger+Eranian says that these bits
>must be zero: page 159, end of first paragraph, `What is unusual is
>that the global-directory index is split into a 7-bit low part (pgdi)
>and a 3 bit high part (pgdh) that covers bits 22 to 39 and 61 to 63
>respectively.  Bits 40 to 60 are unused and must be 0.' (Of course the
>bit numbers here are for 8k pages, and have to be adjusted).


I don't have the book handy, but the relevent chapter is online.  I see
it saying: http://www.phptr.com/articles/article.asp?p)961&seqNum=2

"The unimplemented portion of the virtual address consists of bits
IMPL_VA_MSB + 1 through 60. Even though they are marked as unimplemented,
the architecture requires that the value in these bits match the value
in bit IMPL_VA_MSB. In other words, the unimplemented bits must correspond
to the sign-extended value of the lower portion of the virtual address.
This restriction has been put in place to ensure that software does not
abuse unimplemented bits for purposes such as type tag bits. Otherwise,
such software might break when running on a machine that implements a
larger number of virtual address bits."

Figure 4.13 just below this text shows the hole in the middle
of the region that this creates.

-Tony

