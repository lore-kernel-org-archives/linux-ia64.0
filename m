From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 15 Feb 2022 12:41:08 +0000
Subject: [PATCH v4 13/13] lkdtm: Add a test for function descriptors protection
Message-Id: <7eeba50d16a35e9d799820e43304150225f20197.1644928018.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1644928018.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1644928018.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Add WRITE_OPD to check that you can't modify function
descriptors.

Gives the following result when function descriptors are
not protected:

	lkdtm: Performing direct entry WRITE_OPD
	lkdtm: attempting bad 16 bytes write at c00000000269b358
	lkdtm: FAIL: survived bad write
	lkdtm: do_nothing was hijacked!

Looks like a standard compiler barrier() is not enough to force
GCC to use the modified function descriptor. Had to add a fake empty
inline assembly to force GCC to reload the function descriptor.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
Acked-by: Kees Cook <keescook@chromium.org>
---
 drivers/misc/lkdtm/core.c               |  1 +
 drivers/misc/lkdtm/lkdtm.h              |  1 +
 drivers/misc/lkdtm/perms.c              | 22 ++++++++++++++++++++++
 tools/testing/selftests/lkdtm/tests.txt |  1 +
 4 files changed, 25 insertions(+)

diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index f69b964b9952..e2228b6fc09b 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -149,6 +149,7 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(WRITE_RO),
 	CRASHTYPE(WRITE_RO_AFTER_INIT),
 	CRASHTYPE(WRITE_KERN),
+	CRASHTYPE(WRITE_OPD),
 	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
 	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
 	CRASHTYPE(REFCOUNT_INC_NOT_ZERO_OVERFLOW),
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index d6137c70ebbe..305fc2ec3f25 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -106,6 +106,7 @@ void __init lkdtm_perms_init(void);
 void lkdtm_WRITE_RO(void);
 void lkdtm_WRITE_RO_AFTER_INIT(void);
 void lkdtm_WRITE_KERN(void);
+void lkdtm_WRITE_OPD(void);
 void lkdtm_EXEC_DATA(void);
 void lkdtm_EXEC_STACK(void);
 void lkdtm_EXEC_KMALLOC(void);
diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 1cf24c4a79e9..2c6aba3ff32b 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -44,6 +44,11 @@ static noinline void do_overwritten(void)
 	return;
 }
 
+static noinline void do_almost_nothing(void)
+{
+	pr_info("do_nothing was hijacked!\n");
+}
+
 static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
 {
 	if (!have_function_descriptors())
@@ -144,6 +149,23 @@ void lkdtm_WRITE_KERN(void)
 	do_overwritten();
 }
 
+void lkdtm_WRITE_OPD(void)
+{
+	size_t size = sizeof(func_desc_t);
+	void (*func)(void) = do_nothing;
+
+	if (!have_function_descriptors()) {
+		pr_info("XFAIL: Platform doesn't use function descriptors.\n");
+		return;
+	}
+	pr_info("attempting bad %zu bytes write at %px\n", size, do_nothing);
+	memcpy(do_nothing, do_almost_nothing, size);
+	pr_err("FAIL: survived bad write\n");
+
+	asm("" : "=m"(func));
+	func();
+}
+
 void lkdtm_EXEC_DATA(void)
 {
 	execute_location(data_area, CODE_WRITE);
diff --git a/tools/testing/selftests/lkdtm/tests.txt b/tools/testing/selftests/lkdtm/tests.txt
index 6b36b7f5dcf9..243c781f0780 100644
--- a/tools/testing/selftests/lkdtm/tests.txt
+++ b/tools/testing/selftests/lkdtm/tests.txt
@@ -44,6 +44,7 @@ ACCESS_NULL
 WRITE_RO
 WRITE_RO_AFTER_INIT
 WRITE_KERN
+WRITE_OPD
 REFCOUNT_INC_OVERFLOW
 REFCOUNT_ADD_OVERFLOW
 REFCOUNT_INC_NOT_ZERO_OVERFLOW
-- 
2.34.1
