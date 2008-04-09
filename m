From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 09 Apr 2008 03:26:10 +0000
Subject: [PATCH][for -mm] ia64: pgd_offset() constfication.
Message-Id: <20080409121930.944D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


when compile 2.6.25-rc8-mm1, bellow warning happend.
because walk_page_range pass argument as "const struct mm*", 
but pgd_offset() receive as "struct mm*".

I fixed it.
(no functional change)

---------------------------------------------------------------
  CC      mm/pagewalk.o
mm/pagewalk.c: In function 'walk_page_range':
mm/pagewalk.c:111: warning: passing argument 1 of 'pgd_offset' discards qualifiers from pointer target type



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/asm-ia64/pgtable.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/include/asm-ia64/pgtable.h
=================================--- a/include/asm-ia64/pgtable.h        2008-04-04 12:24:18.000000000 +0900
+++ b/include/asm-ia64/pgtable.h        2008-04-09 12:42:49.000000000 +0900
@@ -374,7 +374,7 @@ pgd_index (unsigned long address)
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the level-1 bits.  */
 static inline pgd_t*
-pgd_offset (struct mm_struct *mm, unsigned long address)
+pgd_offset (const struct mm_struct *mm, unsigned long address)
 {
        return mm->pgd + pgd_index(address);
 }


