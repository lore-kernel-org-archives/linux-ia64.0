From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:06 +0000
Subject: [PATCH 0151/1529] Fix typo
Message-Id: <20160521115606.7370-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/module.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/module.h b/arch/ia64/include/asm/module.h
index f31894b..874f3e1 100644
--- a/arch/ia64/include/asm/module.h
+++ b/arch/ia64/include/asm/module.h
@@ -10,7 +10,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-struct elf64_shdr;			/* forward declration */
+struct elf64_shdr;			/* forward declaration */
 
 struct mod_arch_specific {
 	struct elf64_shdr *core_plt;	/* core PLT section */
-- 
2.8.2.534.g1f66975

