From: Jerry Feldman <gerald.feldman@hp.com>
Date: Fri, 29 Apr 2005 18:43:15 +0000
Subject: Incorrect return types for atomic64 functions in IA64 atomic.h
Message-Id: <200504291443.16040.gerald.feldman@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The return values for the atomic64 functions in /usr/include/asm/atomic.h 
are defined as int and should be __s64 to match the type of the input 
parameter and local variable returned. My patch follows:
----------------------------------------
--- atomic.h.orig       2005-04-29 14:30:34.660126000 -0400
+++ atomic.h    2005-04-29 14:32:57.533791322 -0400
@@ -48,7 +48,7 @@ ia64_atomic_add (int i, atomic_t *v)
        return new;
 }
 
-static __inline__ int
+static __inline__ __s64
 ia64_atomic64_add (__s64 i, atomic64_t *v)
 {
        __s64 old, new;
@@ -76,7 +76,7 @@ ia64_atomic_sub (int i, atomic_t *v)
        return new;
 }
 
-static __inline__ int
+static __inline__ __s64
 ia64_atomic64_sub (__s64 i, atomic64_t *v)
 {
        __s64 old, new;
@@ -124,7 +124,7 @@ atomic_add_negative (int i, atomic_t *v)
        return atomic_add_return(i, v) < 0;
 }
 
-static __inline__ int
+static __inline__ __s64
 atomic64_add_negative (__s64 i, atomic64_t *v)
 {
        return atomic64_add_return(i, v) < 0;
-------------------------------------------------------
-- 
Jerry Feldman <gerald.feldman@hp.com>
Partner Technology Access Center (contractor) (PTAC-MA)
Hewlett-Packard Co.
550 King Street LKG2a-X2
Littleton, Ma. 01460
 (978)506-5243
