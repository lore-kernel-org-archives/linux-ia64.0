From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:35 +0000
Subject: [PATCH v1 08/10] lkdtm: Really write into kernel text in WRITE_KERN
Message-Id: <624940395e5d81967246f911a65740b9a15b5a70.1633964380.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

WRITE_KERN is supposed to overwrite some kernel text, namely
do_overwritten() function.

But at the time being it overwrites do_overwritten() function
descriptor, not function text.

Fix it by dereferencing the function descriptor to obtain
function text pointer.

And make do_overwritten() noinline so that it is really
do_overwritten() which is called by lkdtm_WRITE_KERN().

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 drivers/misc/lkdtm/perms.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 60b3b2fe929d..442d60ed25ef 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -5,6 +5,7 @@
  * even non-readable regions.
  */
 #include "lkdtm.h"
+#include <linux/kallsyms.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mman.h>
@@ -37,7 +38,7 @@ static noinline void do_nothing(void)
 }
 
 /* Must immediately follow do_nothing for size calculuations to work out. */
-static void do_overwritten(void)
+static noinline void do_overwritten(void)
 {
 	pr_info("do_overwritten wasn't overwritten!\n");
 	return;
@@ -113,8 +114,9 @@ void lkdtm_WRITE_KERN(void)
 	size_t size;
 	volatile unsigned char *ptr;
 
-	size = (unsigned long)do_overwritten - (unsigned long)do_nothing;
-	ptr = (unsigned char *)do_overwritten;
+	size = (unsigned long)dereference_symbol_descriptor(do_overwritten) -
+	       (unsigned long)dereference_symbol_descriptor(do_nothing);
+	ptr = dereference_symbol_descriptor(do_overwritten);
 
 	pr_info("attempting bad %zu byte write at %px\n", size, ptr);
 	memcpy((void *)ptr, (unsigned char *)do_nothing, size);
-- 
2.31.1
