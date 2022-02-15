From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:41:06 +0000
Subject: [PATCH v4 11/13] lkdtm: Really write into kernel text in WRITE_KERN
Message-Id: <31e58eaffb5bc51c07d8d4891d1982100ade8cfc.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
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
function text pointer. Export dereference_function_descriptor()
for when LKDTM is built as a module.

And make do_overwritten() noinline so that it is really
do_overwritten() which is called by lkdtm_WRITE_KERN().

Acked-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 drivers/misc/lkdtm/perms.c | 8 +++++---
 kernel/extable.c           | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 60b3b2fe929d..035fcca441f0 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -10,6 +10,7 @@
 #include <linux/mman.h>
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
+#include <asm/sections.h>
 
 /* Whether or not to fill the target memory area with do_nothing(). */
 #define CODE_WRITE	true
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
+	size = (unsigned long)dereference_function_descriptor(do_overwritten) -
+	       (unsigned long)dereference_function_descriptor(do_nothing);
+	ptr = dereference_function_descriptor(do_overwritten);
 
 	pr_info("attempting bad %zu byte write at %px\n", size, ptr);
 	memcpy((void *)ptr, (unsigned char *)do_nothing, size);
diff --git a/kernel/extable.c b/kernel/extable.c
index 394c39b86e38..bda5e9761541 100644
--- a/kernel/extable.c
+++ b/kernel/extable.c
@@ -149,6 +149,7 @@ void *dereference_function_descriptor(void *ptr)
 		ptr = p;
 	return ptr;
 }
+EXPORT_SYMBOL_GPL(dereference_function_descriptor);
 
 void *dereference_kernel_function_descriptor(void *ptr)
 {
-- 
2.34.1
