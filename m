From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Fri, 24 Jun 2022 12:13:13 +0000
Subject: [PATCH v5 9/9] lib: test_bitmap: add compile-time optimization/evaluations assertions
Message-Id: <20220624121313.2382500-10-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220624121313.2382500-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Chancellor <nathan@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Tom Rix <trix@redhat.com>, kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, llvm@lists.linux.dev, linux-kernel@vger.kernel.org

Add a function to the bitmap test suite, which will ensure that
compilers are able to evaluate operations performed by the
bitops/bitmap helpers to compile-time constants when all of the
arguments are compile-time constants as well, or trigger a build
bug otherwise. This should work on all architectures and all the
optimization levels supported by Kbuild.
The function doesn't perform any runtime tests and gets optimized
out to nothing after passing the build assertions.
Unfortunately, Clang for s390 is currently broken (up to the latest
Git snapshots) -- see the comment in the code -- so for now there's
a small workaround for it which doesn't alter the logics. Hope we'll
be able to remove it one day (bugreport is on its way).

Suggested-by: Yury Norov <yury.norov@gmail.com>
Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 lib/test_bitmap.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)

diff --git a/lib/test_bitmap.c b/lib/test_bitmap.c
index d5923a640457..25967cfa4ab2 100644
--- a/lib/test_bitmap.c
+++ b/lib/test_bitmap.c
@@ -869,6 +869,67 @@ static void __init test_bitmap_print_buf(void)
 	}
 }
 
+static void __init test_bitmap_const_eval(void)
+{
+	DECLARE_BITMAP(bitmap, BITS_PER_LONG);
+	unsigned long initvar = BIT(2);
+	unsigned long bitopvar = 0;
+	unsigned long var = 0;
+	int res;
+
+	/*
+	 * Compilers must be able to optimize all of those to compile-time
+	 * constants on any supported optimization level (-O2, -Os) and any
+	 * architecture. Otherwise, trigger a build bug.
+	 * The whole function gets optimized out then, there's nothing to do
+	 * in runtime.
+	 */
+
+	/*
+	 * Equals to `unsigned long bitmap[1] = { GENMASK(6, 5), }`.
+	 * Clang on s390 optimizes bitops at compile-time as intended, but at
+	 * the same time stops treating @bitmap and @bitopvar as compile-time
+	 * constants after regular test_bit() is executed, thus triggering the
+	 * build bugs below. So, call const_test_bit() there directly until
+	 * the compiler is fixed.
+	 */
+	bitmap_clear(bitmap, 0, BITS_PER_LONG);
+#if defined(__s390__) && defined(__clang__)
+	if (!const_test_bit(7, bitmap))
+#else
+	if (!test_bit(7, bitmap))
+#endif
+		bitmap_set(bitmap, 5, 2);
+
+	/* Equals to `unsigned long bitopvar = BIT(20)` */
+	__change_bit(31, &bitopvar);
+	bitmap_shift_right(&bitopvar, &bitopvar, 11, BITS_PER_LONG);
+
+	/* Equals to `unsigned long var = BIT(25)` */
+	var |= BIT(25);
+	if (var & BIT(0))
+		var ^= GENMASK(9, 6);
+
+	/* __const_hweight<32|64>(GENMASK(6, 5)) = 2 */
+	res = bitmap_weight(bitmap, 20);
+	BUILD_BUG_ON(!__builtin_constant_p(res));
+	BUILD_BUG_ON(res != 2);
+
+	/* !(BIT(31) & BIT(18)) = 1 */
+	res = !test_bit(18, &bitopvar);
+	BUILD_BUG_ON(!__builtin_constant_p(res));
+	BUILD_BUG_ON(!res);
+
+	/* BIT(2) & GENMASK(14, 8) = 0 */
+	res = initvar & GENMASK(14, 8);
+	BUILD_BUG_ON(!__builtin_constant_p(res));
+	BUILD_BUG_ON(res);
+
+	/* ~BIT(25) */
+	BUILD_BUG_ON(!__builtin_constant_p(~var));
+	BUILD_BUG_ON(~var != ~BIT(25));
+}
+
 static void __init selftest(void)
 {
 	test_zero_clear();
@@ -884,6 +945,7 @@ static void __init selftest(void)
 	test_for_each_set_clump8();
 	test_bitmap_cut();
 	test_bitmap_print_buf();
+	test_bitmap_const_eval();
 }
 
 KSTM_MODULE_LOADERS(test_bitmap);
-- 
2.36.1
