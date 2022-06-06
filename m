From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Mon, 06 Jun 2022 11:49:07 +0000
Subject: [PATCH 6/6] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <20220606114908.962562-7-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220606114908.962562-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220606114908.962562-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Currently, many architecture-specific non-atomic bitop
implementations use inline asm or other hacks which are faster or
more robust when working with "real" variables (i.e. fields from
the structures etc.), but the compilers have no clue how to optimize
them out when called on compile-time constants. That said, the
following code:

	DECLARE_BITMAP(foo, BITS_PER_LONG) = { }; // -> unsigned long foo[1];
	unsigned long bar = BIT(BAR_BIT);
	unsigned long baz = 0;

	__set_bit(FOO_BIT, foo);
	baz |= BIT(BAZ_BIT);

	BUILD_BUG_ON(!__builtin_constant_p(test_bit(FOO_BIT, foo));
	BUILD_BUG_ON(!__builtin_constant_p(bar & BAR_BIT));
	BUILD_BUG_ON(!__builtin_constant_p(baz & BAZ_BIT));

triggers the first assertion on x86_64, which means that the
compiler is unable to evaluate it to a compile-time initializer
when the architecture-specific bitop is used even if it's obvious.
In order to let the compiler optimize out such cases, expand the
bitop() macro to use the generic C non-atomic bitop implementations
when all of the arguments passed are compile-time constants, which
means that the result will be a compile-time constant as well, so
that it produces more efficient and simple code in 100% cases,
comparing to the architecture-specific counterparts.
The savings on x86_64 with LLVM are insane (.text):

$ scripts/bloat-o-meter -c vmlinux.{base,test}
add/remove: 72/75 grow/shrink: 182/518 up/down: 53925/-137810 (-83885)

$ scripts/bloat-o-meter -c vmlinux.{base,mod}
add/remove: 7/1 grow/shrink: 1/19 up/down: 1135/-4082 (-2947)

$ scripts/bloat-o-meter -c vmlinux.{base,all}
add/remove: 79/76 grow/shrink: 184/537 up/down: 55076/-141892 (-86816)

Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
---
 include/linux/bitops.h | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 33cfc836a115..5788784b2f65 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -33,8 +33,24 @@ extern unsigned long __sw_hweight64(__u64 w);
 
 #include <asm-generic/bitops/generic-non-atomic.h>
 
+/*
+ * Many architecture-specific non-atomic bitops contain inline asm code and due
+ * to that the compiler can't optimize them to compile-time expressions or
+ * constants. In contrary, gen_*() helpers are defined in pure C and compilers
+ * optimize them just well.
+ * Therefore, to make `unsigned long foo = 0; __set_bit(BAR, &foo)` effectively
+ * equal to `unsigned long foo = BIT(BAR)`, pick the generic C alternative when
+ * the arguments can be resolved at compile time. That expression itself is a
+ * constant and doesn't bring any functional changes to the rest of cases.
+ * The casts to `uintptr_t` are needed to mitigate `-Waddress` warnings when
+ * passing a bitmap from .bss or .data (-> `!!addr` is always true).
+ */
 #define bitop(op, nr, addr)						\
-	op(nr, addr)
+	((__builtin_constant_p(nr) &&					\
+	  __builtin_constant_p((uintptr_t)(addr) != (uintptr_t)NULL) &&	\
+	  (uintptr_t)(addr) != (uintptr_t)NULL &&			\
+	  __builtin_constant_p(*(const unsigned long *)(addr))) ?	\
+	 gen##op(nr, addr) : op(nr, addr))
 
 #define __set_bit(nr, addr)		bitop(___set_bit, nr, addr)
 #define __clear_bit(nr, addr)		bitop(___clear_bit, nr, addr)
-- 
2.36.1
