From: Yury Norov <yury.norov@gmail.com>
Date: Sat, 18 Dec 2021 21:20:03 +0000
Subject: [PATCH 07/17] lib/bitmap: add bitmap_weight_{cmp,eq,gt,ge,lt,le} functions
Message-Id: <20211218212014.1315894-8-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211218212014.1315894-1-yury.norov@gmail.com>
In-Reply-To: <20211218212014.1315894-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-kernel@vger.kernel.org, Yury Norov <yury.norov@gmail.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, "Paul E. McKenney" <paulmck@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexey Klimov <aklimov@redhat.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Andy Gross <agross@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Laight <David.Laight@ACULAB.COM>, Dennis Zhou <dennis@kernel.org>, Emil Renner Berthing <kernel@esmil.dk>, Geert Uytterhoeven <geert@linux-m68k.org>, Geetha sowjanya <gakula@marvell.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Hans de Goede <hdegoede@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Ian Rogers <irogers@google.com>, Ingo Molnar <mingo@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Jason Wessel <jason.wessel@windriver.com>, Jens Axboe <axboe@fb.com>, Jiri Olsa <jolsa@redhat.com>, Joe Perches <joe@perches.com>, Jonathan Cameron <jic23@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Lee Jones <lee.jones@linaro.org>, Marc Zyngier <maz@kernel.org>, Marcin Wojtas <mw@semihalf.com>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Nicholas Piggin <npiggin@gmail.com>, Palmer Dabbelt <palmer@dabbelt.com>, Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Russell King <linux@armlinux.org.uk>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Sergey Senozhatsky <senozhatsky@chromium.org>, Solomon Peachy <pizza@shaftnet.org>, Stephen Boyd <sboyd@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Subbaraya Sundeep <sbhatta@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Sunil Goutham <sgoutham@marvell.com>, Tariq Toukan <tariqt@nvidia.com>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Vineet Gupta <vgupta@kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>, bcm-kernel-feedback-list@broadcom.com, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

Many kernel users use bitmap_weight() to compare the result against
some number or expression:

	if (bitmap_weight(...) > 1)
		do_something();

It works OK, but may be significantly improved for large bitmaps: if
first few words count set bits to a number greater than given, we can
stop counting and immediately return.

The same idea would work in other direction: if we know that the number
of set bits that we counted so far is small enough, so that it would be
smaller than required number even if all bits of the rest of the bitmap
are set, we can stop counting earlier.

This patch adds new bitmap_weight_cmp() as suggested by Michał Mirosław
and a family of eq, gt, ge, lt and le wrappers to allow this optimization.
The following patches apply new functions where appropriate.

Suggested-by: "Michał Mirosław" <mirq-linux@rere.qmqm.pl> (for bitmap_weight_cmp)
Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 include/linux/bitmap.h | 80 ++++++++++++++++++++++++++++++++++++++++++
 lib/bitmap.c           | 21 +++++++++++
 2 files changed, 101 insertions(+)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index 7dba0847510c..708e57b32362 100644
--- a/include/linux/bitmap.h
+++ b/include/linux/bitmap.h
@@ -51,6 +51,12 @@ struct device;
  *  bitmap_empty(src, nbits)                    Are all bits zero in *src?
  *  bitmap_full(src, nbits)                     Are all bits set in *src?
  *  bitmap_weight(src, nbits)                   Hamming Weight: number set bits
+ *  bitmap_weight_cmp(src, nbits)               compare Hamming Weight with a number
+ *  bitmap_weight_eq(src, nbits, num)           Hamming Weight = num
+ *  bitmap_weight_gt(src, nbits, num)           Hamming Weight >  num
+ *  bitmap_weight_ge(src, nbits, num)           Hamming Weight >= num
+ *  bitmap_weight_lt(src, nbits, num)           Hamming Weight <  num
+ *  bitmap_weight_le(src, nbits, num)           Hamming Weight <= num
  *  bitmap_set(dst, pos, nbits)                 Set specified bit area
  *  bitmap_clear(dst, pos, nbits)               Clear specified bit area
  *  bitmap_find_next_zero_area(buf, len, pos, n, mask)  Find bit free area
@@ -162,6 +168,7 @@ int __bitmap_intersects(const unsigned long *bitmap1,
 int __bitmap_subset(const unsigned long *bitmap1,
 		    const unsigned long *bitmap2, unsigned int nbits);
 int __bitmap_weight(const unsigned long *bitmap, unsigned int nbits);
+int __bitmap_weight_cmp(const unsigned long *bitmap, unsigned int bits, int num);
 void __bitmap_set(unsigned long *map, unsigned int start, int len);
 void __bitmap_clear(unsigned long *map, unsigned int start, int len);
 
@@ -403,6 +410,79 @@ static __always_inline int bitmap_weight(const unsigned long *src, unsigned int
 	return __bitmap_weight(src, nbits);
 }
 
+/**
+ * bitmap_weight_cmp - compares number of set bits in @src with @num.
+ * @src:   source bitmap
+ * @nbits: length of bitmap in bits
+ * @num:   number to compare with
+ *
+ * As opposite to bitmap_weight() this function doesn't necessarily
+ * traverse full bitmap and may return earlier.
+ *
+ * Returns zero if weight of @src is equal to @num;
+ *	   negative number if weight of @src is less than @num;
+ *	   positive number if weight of @src is greater than @num;
+ *
+ * NOTES
+ *
+ * Because number of set bits cannot decrease while counting, when user
+ * wants to know if the number of set bits in the bitmap is less than
+ * @num, calling
+ *	bitmap_weight_cmp(..., @num) < 0
+ * is potentially less effective than
+ *	bitmap_weight_cmp(..., @num - 1) <= 0
+ *
+ * Consider an example:
+ * bitmap_weight_cmp(1000 0000 0000 0000, 1) < 0
+ *				    ^
+ *				    stop here
+ *
+ * bitmap_weight_cmp(1000 0000 0000 0000, 0) <= 0
+ *		     ^
+ *		     stop here
+ */
+static __always_inline
+int bitmap_weight_cmp(const unsigned long *src, unsigned int nbits, int num)
+{
+	if (num > (int)nbits || num < 0)
+		return -num;
+
+	if (small_const_nbits(nbits))
+		return hweight_long(*src & BITMAP_LAST_WORD_MASK(nbits)) - num;
+
+	return __bitmap_weight_cmp(src, nbits, num);
+}
+
+static __always_inline
+bool bitmap_weight_eq(const unsigned long *src, unsigned int nbits, int num)
+{
+	return bitmap_weight_cmp(src, nbits, num) = 0;
+}
+
+static __always_inline
+bool bitmap_weight_gt(const unsigned long *src, unsigned int nbits, int num)
+{
+	return bitmap_weight_cmp(src, nbits, num) > 0;
+}
+
+static __always_inline
+bool bitmap_weight_ge(const unsigned long *src, unsigned int nbits, int num)
+{
+	return bitmap_weight_cmp(src, nbits, num - 1) > 0;
+}
+
+static __always_inline
+bool bitmap_weight_lt(const unsigned long *src, unsigned int nbits, int num)
+{
+	return bitmap_weight_cmp(src, nbits, num - 1) <= 0;
+}
+
+static __always_inline
+bool bitmap_weight_le(const unsigned long *src, unsigned int nbits, int num)
+{
+	return bitmap_weight_cmp(src, nbits, num) <= 0;
+}
+
 static __always_inline void bitmap_set(unsigned long *map, unsigned int start,
 		unsigned int nbits)
 {
diff --git a/lib/bitmap.c b/lib/bitmap.c
index 926408883456..fb84ca70c5d9 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -348,6 +348,27 @@ int __bitmap_weight(const unsigned long *bitmap, unsigned int bits)
 }
 EXPORT_SYMBOL(__bitmap_weight);
 
+int __bitmap_weight_cmp(const unsigned long *bitmap, unsigned int bits, int num)
+{
+	unsigned int k, w, lim = bits / BITS_PER_LONG;
+
+	for (k = 0, w = 0; k < lim; k++) {
+		if (w + bits - k * BITS_PER_LONG < num)
+			goto out;
+
+		w += hweight_long(bitmap[k]);
+
+		if (w > num)
+			goto out;
+	}
+
+	if (bits % BITS_PER_LONG)
+		w += hweight_long(bitmap[k] & BITMAP_LAST_WORD_MASK(bits));
+out:
+	return w - num;
+}
+EXPORT_SYMBOL(__bitmap_weight_cmp);
+
 void __bitmap_set(unsigned long *map, unsigned int start, int len)
 {
 	unsigned long *p = map + BIT_WORD(start);
-- 
2.30.2
