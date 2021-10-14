From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 14 Oct 2021 05:50:01 +0000
Subject: [PATCH v2 12/13] lkdtm: Fix execute_[user]_location()
Message-Id: <cbee30c66890994e116a8eae8094fa8c5336f90a.1634190022.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

execute_location() and execute_user_location() intent
to copy do_nothing() text and execute it at a new location.
However, at the time being it doesn't copy do_nothing() function
but do_nothing() function descriptor which still points to the
original text. So at the end it still executes do_nothing() at
its original location allthough using a copied function descriptor.

So, fix that by really copying do_nothing() text and build a new
function descriptor by copying do_nothing() function descriptor and
updating the target address with the new location.

Also fix the displayed addresses by dereferencing do_nothing()
function descriptor.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 drivers/misc/lkdtm/perms.c     | 25 +++++++++++++++++++++----
 include/asm-generic/sections.h |  5 +++++
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 5266dc28df6e..96b3ebfcb8ed 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -44,19 +44,32 @@ static noinline void do_overwritten(void)
 	return;
 }
 
+static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
+{
+	memcpy(fdesc, do_nothing, sizeof(*fdesc));
+	fdesc->addr = (unsigned long)dst;
+	barrier();
+
+	return fdesc;
+}
+
 static noinline void execute_location(void *dst, bool write)
 {
 	void (*func)(void) = dst;
+	func_desc_t fdesc;
+	void *do_nothing_text = dereference_function_descriptor(do_nothing);
 
-	pr_info("attempting ok execution at %px\n", do_nothing);
+	pr_info("attempting ok execution at %px\n", do_nothing_text);
 	do_nothing();
 
 	if (write = CODE_WRITE) {
-		memcpy(dst, do_nothing, EXEC_SIZE);
+		memcpy(dst, do_nothing_text, EXEC_SIZE);
 		flush_icache_range((unsigned long)dst,
 				   (unsigned long)dst + EXEC_SIZE);
 	}
 	pr_info("attempting bad execution at %px\n", func);
+	if (have_function_descriptors())
+		func = setup_function_descriptor(&fdesc, dst);
 	func();
 	pr_err("FAIL: func returned\n");
 }
@@ -67,15 +80,19 @@ static void execute_user_location(void *dst)
 
 	/* Intentionally crossing kernel/user memory boundary. */
 	void (*func)(void) = dst;
+	func_desc_t fdesc;
+	void *do_nothing_text = dereference_function_descriptor(do_nothing);
 
-	pr_info("attempting ok execution at %px\n", do_nothing);
+	pr_info("attempting ok execution at %px\n", do_nothing_text);
 	do_nothing();
 
-	copied = access_process_vm(current, (unsigned long)dst, do_nothing,
+	copied = access_process_vm(current, (unsigned long)dst, do_nothing_text,
 				   EXEC_SIZE, FOLL_WRITE);
 	if (copied < EXEC_SIZE)
 		return;
 	pr_info("attempting bad execution at %px\n", func);
+	if (have_function_descriptors())
+		func = setup_function_descriptor(&fdesc, dst);
 	func();
 	pr_err("FAIL: func returned\n");
 }
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 76163883c6ff..d225318538bd 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -70,6 +70,11 @@ typedef struct {
 } func_desc_t;
 #endif
 
+static inline bool have_function_descriptors(void)
+{
+	return __is_defined(HAVE_FUNCTION_DESCRIPTORS);
+}
+
 /* random extra sections (if any).  Override
  * in asm/sections.h */
 #ifndef arch_is_kernel_text
-- 
2.31.1
