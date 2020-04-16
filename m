From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 16 Apr 2020 22:01:19 +0000
Subject: [PATCH v3 00/11] Make PageWriteback use the PageLocked optimisation
Message-Id: <20200416220130.13343-1-willy@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

PageWaiters is used by PageWriteback and PageLocked (and no other page
flags), so it makes sense to use the same codepaths that have already been
optimised for PageLocked, even if there's probably no real performance
benefit to be had.

Unfortunately, clear_bit_unlock_is_negative_byte() isn't present on every
architecture, and the default implementation is only available in filemap.c
while I want to use it in page-writeback.c.  Rather than move the default
implementation to a header file, I've done optimised implementations for
alpha and ia64.  I can't figure out optimised implementations for m68k,
mips, riscv and s390, so I've just replicated the effect of the generic
implementation in them.  I leave it to the experts to fix that (... or
convert over to using asm-generic/bitops/lock.h ...)

v3:
 - Added implementations of clear_bit_unlock_is_negative_byte()
   to architectures which need it

v2: Rebased to 5.7-rc1
 - Split up patches better
 - Moved the BUG() from end_page_writeback() to __clear_page_writeback()
   as requested by Jan Kara.
 - Converted the BUG() to WARN_ON()
 - Removed TestClearPageWriteback

Matthew Wilcox (Oracle) (11):
  alpha: Add clear_bit_unlock_is_negative_byte implementation
  ia64: Add clear_bit_unlock_is_negative_byte implementation
  m68k: Add clear_bit_unlock_is_negative_byte implementation
  mips: Add clear_bit_unlock_is_negative_byte implementation
  riscv: Add clear_bit_unlock_is_negative_byte implementation
  s390: Add clear_bit_unlock_is_negative_byte implementation
  mm: Remove definition of clear_bit_unlock_is_negative_byte
  mm: Move PG_writeback into the bottom byte
  mm: Convert writeback BUG to WARN_ON
  mm: Use clear_bit_unlock_is_negative_byte for PageWriteback
  mm: Remove TestClearPageWriteback

 arch/alpha/include/asm/bitops.h | 23 ++++++++++++++++++
 arch/ia64/include/asm/bitops.h  | 20 ++++++++++++++++
 arch/m68k/include/asm/bitops.h  |  7 ++++++
 arch/mips/include/asm/bitops.h  |  7 ++++++
 arch/riscv/include/asm/bitops.h |  7 ++++++
 arch/s390/include/asm/bitops.h  |  9 +++++++
 include/linux/page-flags.h      |  8 +++----
 mm/filemap.c                    | 41 ++++----------------------------
 mm/page-writeback.c             | 42 ++++++++++++++++++++-------------
 9 files changed, 107 insertions(+), 57 deletions(-)

-- 
2.25.1
