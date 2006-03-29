From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 00:49:24 +0000
Subject: Add full memory fence for test_and_*_bit operation
Message-Id: <200603290048.k2T0mmg32601@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, semi-big-hammer to enforce full memory fence on ia64 for
test_and_set_bit
test_and_clear_bit
test_and_change_bit

It's sad we don't have something like:

test_and_set_bit_used_like_a_lock
test_and_set_bit_used_like_an_unlock
test_and_set_bit_full_memory_fence
test_and_clear_bit_used_like_a_lock
test_and_clear_bit_used_like_an_unlock
test_and_clear_bit_full_memory_fence
test_and_change_bit_used_like_a_lock
test_and_change_bit_used_like_an_unlock
test_and_change_bit_full_memory_fence

- Ken


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./include/asm-ia64/bitops.h.orig	2006-03-28 17:30:33.000000000 -0800
+++ ./include/asm-ia64/bitops.h	2006-03-28 17:31:30.000000000 -0800
@@ -166,7 +166,7 @@ test_and_set_bit (int nr, volatile void 
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old | bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
@@ -211,7 +211,7 @@ test_and_clear_bit (int nr, volatile voi
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old & mask;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & ~mask) != 0;
 }
 
@@ -256,7 +256,7 @@ test_and_change_bit (int nr, volatile vo
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old ^ bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
