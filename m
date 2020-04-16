From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 16 Apr 2020 22:01:21 +0000
Subject: [PATCH v3 02/11] ia64: Add clear_bit_unlock_is_negative_byte implementation
Message-Id: <20200416220130.13343-3-willy@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200416220130.13343-1-willy@infradead.org>
In-Reply-To: <20200416220130.13343-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Copy and paste the clear_bit_unlock() implementation, and test the old
variable to see if it has bit 7 set.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/bitops.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/ia64/include/asm/bitops.h b/arch/ia64/include/asm/bitops.h
index 2f24ee6459d2..ba92ca44731b 100644
--- a/arch/ia64/include/asm/bitops.h
+++ b/arch/ia64/include/asm/bitops.h
@@ -117,6 +117,26 @@ clear_bit_unlock (int nr, volatile void *addr)
 	} while (cmpxchg_rel(m, old, new) != old);
 }
 
+static inline bool clear_bit_unlock_is_negative_byte(unsigned int nr,
+						volatile unsigned long *p)
+{
+	__u32 mask, old, new;
+	volatile __u32 *m;
+	CMPXCHG_BUGCHECK_DECL
+
+	m = (volatile __u32 *) addr + (nr >> 5);
+	mask = ~(1 << (nr & 31));
+	do {
+		CMPXCHG_BUGCHECK(m);
+		old = *m;
+		new = old & mask;
+	} while (cmpxchg_rel(m, old, new) != old);
+
+	return old & (1 << 7);
+}
+#define clear_bit_unlock_is_negative_byte \
+	clear_bit_unlock_is_negative_byte
+
 /**
  * __clear_bit_unlock - Non-atomically clears a bit in memory with release
  * @nr: Bit to clear
-- 
2.25.1
