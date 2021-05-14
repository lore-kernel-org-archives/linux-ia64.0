From: Arnd Bergmann <arnd@kernel.org>
Date: Fri, 14 May 2021 21:41:15 +0000
Subject: [PATCH] ia64: mca_drv: fix incorrect array size calculation
Message-Id: <20210514214123.875971-1-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Masahiro Yamada <masahiroy@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

gcc points out a mistake in the mca driver that goes back
to before the git history:

arch/ia64/kernel/mca_drv.c: In function 'init_record_index_pools':
arch/ia64/kernel/mca_drv.c:346:54: error: expression does not compute the number of elements in this array; element typ
e is 'int', not 'size_t' {aka 'long unsigned int'} [-Werror=sizeof-array-div]
  346 |         for (i = 1; i < sizeof sal_log_sect_min_sizes/sizeof(size_t); i++)
      |                                                      ^

This is the same as sizeof(size_t), which is two shorter than the
actual array. Use the ARRAY_SIZE() macro to get the correct
calculation instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/mca_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 36a69b4e6169..5bfc79be4cef 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -343,7 +343,7 @@ init_record_index_pools(void)
 
 	/* - 2 - */
 	sect_min_size = sal_log_sect_min_sizes[0];
-	for (i = 1; i < sizeof sal_log_sect_min_sizes/sizeof(size_t); i++)
+	for (i = 1; i < ARRAY_SIZE(sal_log_sect_min_sizes); i++)
 		if (sect_min_size > sal_log_sect_min_sizes[i])
 			sect_min_size = sal_log_sect_min_sizes[i];
 
-- 
2.29.2
