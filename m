From: Bhaskar Chowdhury <unixbhaskar@gmail.com>
Date: Sat, 13 Mar 2021 04:58:37 +0000
Subject: [PATCH] ia64: include: asm: Minor typo fixes in the file pgtable.h
Message-Id: <20210313045519.9310-1-unixbhaskar@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rppt@kernel.org, akpm@linux-foundation.org, unixbhaskar@gmail.com, deller@gmx.de, shorne@gmail.com, anshuman.khandual@arm.com, jrtc27@jrtc27.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: rdunlap@infradead.org


s/migraton/migration/

Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
---
 arch/ia64/include/asm/pgtable.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 9b4efe89e62d..00a76ed7e018 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -328,7 +328,7 @@ extern void __ia64_sync_icache_dcache(pte_t pteval);
 static inline void set_pte(pte_t *ptep, pte_t pteval)
 {
 	/* page is present && page is user  && page is executable
-	 * && (page swapin or new page or page migraton
+	 * && (page swapin or new page or page migration
 	 *	|| copy_on_write with page copying.)
 	 */
 	if (pte_present_exec_user(pteval) &&
--
2.26.2
