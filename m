From: Gary Hade <garyhade@us.ibm.com>
Date: Fri, 05 Apr 2002 21:40:34 +0000
Subject: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905396@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

asm/atomic.h is not palatable to C++ due to it's use 
of the C++ keyword "new".

Script started on Fri Apr  5 12:03:38 2002
elm3a87.eng:/home/garyh cat x.C
#include <asm/atomic.h>
elm3a87.eng:/home/garyh c++ -c x.C
In file included from x.C:1:
/usr/include/asm/atomic.h: In function `int ia64_atomic_add (int,
atomic_t *)':
/usr/include/asm/atomic.h:33: parse error before `new'
/usr/include/asm/atomic.h:39: parse error before `='
/usr/include/asm/atomic.h:41: parse error before `;'
/usr/include/asm/atomic.h: In function `int ia64_atomic_sub (int,
atomic_t *)':
/usr/include/asm/atomic.h:47: parse error before `new'
/usr/include/asm/atomic.h:53: parse error before `='
/usr/include/asm/atomic.h:54: parse error before `)'
/usr/include/asm/atomic.h:54: `_n_' undeclared (first use this
function)
/usr/include/asm/atomic.h:54: (Each undeclared identifier is reported
only once for each function it appears in.)
/usr/include/asm/atomic.h:55: parse error before `;'
elm3a87.eng:/home/garyh exit
exit

Script done on Fri Apr	5 12:03:55 2002

Patch for 2.4.18 included below.

Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc


--- linux/include/asm-ia64/atomic.h.orig	Fri Apr  5 11:56:12 2002
+++ linux/include/asm-ia64/atomic.h	Fri Apr  5 11:55:21 2002
@@ -30,29 +30,29 @@
 static __inline__ int
 ia64_atomic_add (int i, atomic_t *v)
 {
-	__s32 old, new;
+	__s32 old_val, new_val;
 	CMPXCHG_BUGCHECK_DECL
 
 	do {
 		CMPXCHG_BUGCHECK(v);
-		old = atomic_read(v);
-		new = old + i;
-	} while (ia64_cmpxchg("acq", v, old, old + i, sizeof(atomic_t)) != old);
-	return new;
+		old_val = atomic_read(v);
+		new_val = old_val + i;
+	} while (ia64_cmpxchg("acq", v, old_val, old_val + i, sizeof(atomic_t)) != old_val);
+	return new_val;
 }
 
 static __inline__ int
 ia64_atomic_sub (int i, atomic_t *v)
 {
-	__s32 old, new;
+	__s32 old_val, new_val;
 	CMPXCHG_BUGCHECK_DECL
 
 	do {
 		CMPXCHG_BUGCHECK(v);
-		old = atomic_read(v);
-		new = old - i;
-	} while (ia64_cmpxchg("acq", v, old, new, sizeof(atomic_t)) != old);
-	return new;
+		old_val = atomic_read(v);
+		new_val = old_val - i;
+	} while (ia64_cmpxchg("acq", v, old_val, new_val, sizeof(atomic_t)) != old_val);
+	return new_val;
 }
 
 /*

