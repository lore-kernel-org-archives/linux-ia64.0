From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 21 Jul 2009 15:09:44 +0000
Subject: [patch] ia64: boolean __test_and_clear_bit
Message-Id: <1248188984-10148-1-git-send-email-hannes@cmpxchg.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

__test_and_clear_bit() returns a bitfield with the tested-for bit set.
Make it consistent with the other bitops - of ia64 but also every
other architecture - and return a boolean value.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/ia64/include/asm/bitops.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/bitops.h b/arch/ia64/include/asm/bitops.h
index e2ca800..57a2787 100644
--- a/arch/ia64/include/asm/bitops.h
+++ b/arch/ia64/include/asm/bitops.h
@@ -286,7 +286,7 @@ __test_and_clear_bit(int nr, volatile void * addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
-	int oldbitset = *p & m;
+	int oldbitset = (*p & m) != 0;
 
 	*p &= ~m;
 	return oldbitset;
-- 
1.6.3

