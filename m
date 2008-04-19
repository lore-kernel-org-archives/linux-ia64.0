From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 19 Apr 2008 10:07:02 +0000
Subject: [PATCH][trivial][1/2] ia64: add constfy to pgd_offset()
Message-Id: <20080419190442.A8F4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080419184918.A8EE.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080419185723.A8F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080419185723.A8F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, dev-etrax@axis.com, "Luck, Tony" <tony.luck@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com

add constfy to pgd_offset() for avoid following warnings.

  CC      mm/pagewalk.o
mm/pagewalk.c: In function 'walk_page_range':
mm/pagewalk.c:111: warning: passing argument 1 of 'pgd_offset' discards qualifiers from p\
ointer target type




Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Matt Mackall <mpm@selenic.com>
CC: "Vegard Nossum" <vegard.nossum@gmail.com>
CC: "Luck, Tony" <tony.luck@intel.com>

---
 include/asm-ia64/pgtable.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/include/asm-ia64/pgtable.h
=================================--- a/include/asm-ia64/pgtable.h        2008-04-19 17:46:11.000000000 +0900
+++ b/include/asm-ia64/pgtable.h        2008-04-19 19:20:16.000000000 +0900
@@ -371,7 +371,7 @@ pgd_index (unsigned long address)
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the level-1 bits.  */
 static inline pgd_t*
-pgd_offset (struct mm_struct *mm, unsigned long address)
+pgd_offset (const struct mm_struct *mm, unsigned long address)
 {
        return mm->pgd + pgd_index(address);
 }



