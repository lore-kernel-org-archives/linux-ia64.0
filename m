From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Thu, 15 Oct 2009 06:07:07 +0000
Subject: [PATCH -mmotm -v2] Fix
Message-Id: <20091015060706.GA26956@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com> <1255076961-21325-2-git-send-email-akinobu.mita@gmail.com> <20091009164100.85a36188.akpm@linux-foundation.org> <20091013021818.GA3898@localhost.localdomain> <20091013091017.GA18431@localhost.localdomain> <20091014032258.GA18527@localhost.localdomain>
In-Reply-To: <20091014032258.GA18527@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, Lothar Wassmann <LW@KARO-electronics.de>, linux-usb@vger.kernel.org, Roland Dreier <rolandd@cisco.com>, Yevgeny Petrilin <yevgenyp@mellanox.co.il>, netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-altix@sgi.com, Kyle Hubert <khubert@gmail.com>

From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Fix bitmap-introduce-bitmap_set-bitmap_clear-bitmap_find_next_zero_area.patch

- Rewrite bitmap_set and bitmap_clear

  Instead of setting or clearing for each bit.

- Fix off-by-one errors in bitmap_find_next_zero_area

  This bug was derived from find_next_zero_area in iommu-helper.

- Add kerneldoc for bitmap_find_next_zero_area

This patch is supposed to be folded into
bitmap-introduce-bitmap_set-bitmap_clear-bitmap_find_next_zero_area.patch

* -v2
- Remove an extra test at the "index" value by find_next_bit

Index was just returned by find_next_zero_bit, so we know it's zero.

Noticed-by: Kyle Hubert <khubert@gmail.com>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 lib/bitmap.c |   62 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/lib/bitmap.c b/lib/bitmap.c
index 2415da4..962b863 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -271,28 +271,62 @@ int __bitmap_weight(const unsigned long *bitmap, int bits)
 }
 EXPORT_SYMBOL(__bitmap_weight);
 
-void bitmap_set(unsigned long *map, int i, int len)
-{
-	int end = i + len;
+#define BITMAP_FIRST_WORD_MASK(start) (~0UL << ((start) % BITS_PER_LONG))
 
-	while (i < end) {
-		__set_bit(i, map);
-		i++;
+void bitmap_set(unsigned long *map, int start, int nr)
+{
+	unsigned long *p = map + BIT_WORD(start);
+	const int size = start + nr;
+	int bits_to_set = BITS_PER_LONG - (start % BITS_PER_LONG);
+	unsigned long mask_to_set = BITMAP_FIRST_WORD_MASK(start);
+
+	while (nr - bits_to_set >= 0) {
+		*p |= mask_to_set;
+		nr -= bits_to_set;
+		bits_to_set = BITS_PER_LONG;
+		mask_to_set = ~0UL;
+		p++;
+	}
+	if (nr) {
+		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
+		*p |= mask_to_set;
 	}
 }
 EXPORT_SYMBOL(bitmap_set);
 
 void bitmap_clear(unsigned long *map, int start, int nr)
 {
-	int end = start + nr;
-
-	while (start < end) {
-		__clear_bit(start, map);
-		start++;
+	unsigned long *p = map + BIT_WORD(start);
+	const int size = start + nr;
+	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
+	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);
+
+	while (nr - bits_to_clear >= 0) {
+		*p &= ~mask_to_clear;
+		nr -= bits_to_clear;
+		bits_to_clear = BITS_PER_LONG;
+		mask_to_clear = ~0UL;
+		p++;
+	}
+	if (nr) {
+		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
+		*p &= ~mask_to_clear;
 	}
 }
 EXPORT_SYMBOL(bitmap_clear);
 
+/*
+ * bitmap_find_next_zero_area - find a contiguous aligned zero area
+ * @map: The address to base the search on
+ * @size: The bitmap size in bits
+ * @start: The bitnumber to start searching at
+ * @nr: The number of zeroed bits we're looking for
+ * @align_mask: Alignment mask for zero area
+ *
+ * The @align_mask should be one less than a power of 2; the effect is that
+ * the bit offset of all zero areas this function finds is multiples of that
+ * power of 2. A @align_mask of 0 means no alignment is required.
+ */
 unsigned long bitmap_find_next_zero_area(unsigned long *map,
 					 unsigned long size,
 					 unsigned long start,
@@ -304,12 +338,12 @@ again:
 	index = find_next_zero_bit(map, size, start);
 
 	/* Align allocation */
-	index = (index + align_mask) & ~align_mask;
+	index = __ALIGN_MASK(index, align_mask);
 
 	end = index + nr;
-	if (end >= size)
+	if (end > size)
 		return end;
-	i = find_next_bit(map, end, index);
+	i = find_next_bit(map, end, index + 1);
 	if (i < end) {
 		start = i + 1;
 		goto again;
-- 
1.5.4.3

