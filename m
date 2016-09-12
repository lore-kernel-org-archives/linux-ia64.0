From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Mon, 12 Sep 2016 17:58:02 +0000
Subject: [PATCH v3 1/2] ia64: implement atomic64_dec_if_positive
Message-Id: <1473703083-8625-2-git-send-email-vgupta@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201609111259.q67d9T4B%fengguang.wu@intel.com>
 <1473703083-8625-1-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1473703083-8625-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>, linux-ia64@vger.kernel.org

This is based on s390 version and needed to get rid of
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/ia64/include/asm/atomic.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index f565ad376142..65d4bb2b6685 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -269,6 +269,22 @@ static __inline__ long atomic64_add_unless(atomic64_t *v, long a, long u)
 
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
 
+static __inline__ long atomic64_dec_if_positive(atomic64_t *v)
+{
+	long c, old, dec;
+	c = atomic64_read(v);
+	for (;;) {
+		dec = c - 1;
+		if (unlikely(dec < 0))
+			break;
+		old = atomic64_cmpxchg((v), c, dec);
+		if (likely(old = c))
+			break;
+		c = old;
+	}
+	return dec;
+}
+
 /*
  * Atomically add I to V and return TRUE if the resulting value is
  * negative.
-- 
2.7.4

