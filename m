From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 17 Mar 2005 22:04:44 +0000
Subject: Recent fix for pgd_addr_end
Message-Id: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
  In the recent fix to include/asm-ia64/pgtable.,h, the coode now
sign-extends the top of the pgdindex into the reserved region.

Are you sure this is correct?  Mosberger+Eranian says that these bits
must be zero: page 159, end of first paragraph, `What is unusual is
that the global-directory index is split into a 7-bit low part (pgdi)
and a 3 bit high part (pgdh) that covers bits 22 to 39 and 61 to 63
respectively.  Bits 40 to 60 are unused and must be 0.' (Of course the
bit numbers here are for 8k pages, and have to be adjusted).



-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
