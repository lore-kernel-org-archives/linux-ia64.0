From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 08 Jul 2004 22:39:58 +0000
Subject: [PATCH] Bug in ia64_atomic64_{add,sub}
Message-Id: <Pine.SGI.4.58.0407081731470.87305@kzerza.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hit this bug just yesterday.  I hope the problem and fix require no
explanation.  Patched kernel boots and runs just fine.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>

=====================================Index: linux/include/asm-ia64/atomic.h
=====================================
--- linux.orig/include/asm-ia64/atomic.h	2004-07-08 17:24:37.000000000 -0500
+++ linux/include/asm-ia64/atomic.h	2004-07-08 10:37:44.000000000 -0500
@@ -56,7 +56,7 @@
 		CMPXCHG_BUGCHECK(v);
 		old = atomic_read(v);
 		new = old + i;
-	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic_t)) != old);
+	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic64_t)) != old);
 	return new;
 }

@@ -84,7 +84,7 @@
 		CMPXCHG_BUGCHECK(v);
 		old = atomic_read(v);
 		new = old - i;
-	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic_t)) != old);
+	} while (ia64_cmpxchg(acq, v, old, new, sizeof(atomic64_t)) != old);
 	return new;
 }

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
