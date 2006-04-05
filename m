From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 05 Apr 2006 15:30:34 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning
Message-Id: <4433E29A.5010300@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010503030109080003070501"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010503030109080003070501
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Christoph Lameter wrote:

> Could you come up with a patch? Currently, I do not seem to be able to 
> spend enough time on it.

Please have a look at this patch.

Temporary solution while we are waiting for:

	test_and_set_bit (int nr, volatile void *addr, MODE_BARRIER)

& co.

Changing the temp. variables to be 64 bit wide was not a good idea => alignment faults.
In order to eliminate the extra "zxt4", I hanged the type of the return values of my
intrinsic macros to be 32 bit wide. Here is what I get (NOP-s removed):

reserve_bootmem_core+240:  [MMI]       mf;;
reserve_bootmem_core+241:              and r10=31,r18
reserve_bootmem_core+257:              extr r11=r18,5,27;;
reserve_bootmem_core+272:  [MFI]       shladd r16=r11,2,r16
reserve_bootmem_core+274:              shl r17=r19,r10;;
reserve_bootmem_core+288:  [MMI]       ld4.bias.nta r20=[r16];;
reserve_bootmem_core+289:              or r22=r17,r20
reserve_bootmem_core+305:              mov.m ar.ccv=r20;;
reserve_bootmem_core+320:  [MMI]       cmpxchg4.acq.nta r21=[r16],r22,ar.ccv;;
reserve_bootmem_core+322:              cmp4.eq p14,p15=r20,r21
reserve_bootmem_core+336:  [BBB] (p15) br.cond.dptk.few reserve_bootmem_core+288

BTW why do all the intrinsic macros return 64 bit wide values, independently of
their actual operand width? E.g.:

#define ia64_cmpxchg4_acq(ptr, new, old)
...
	__u64 ia64_intri_res;

Thanks,

Zoltan

Signed-off-by: Zoltan Menyhart <Zoltan.Menyhart@bull.net>

--------------010503030109080003070501
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

--- old/include/asm-ia64/bitops.h	2006-04-04 18:19:50.000000000 +0200
+++ linux-2.6.16/include/asm-ia64/bitops.h	2006-04-05 16:49:12.000000000 +0200
@@ -7,6 +7,19 @@
  *
  * 02/06/02 find_next_bit() and find_first_bit() added from Erich Focht's ia64 O(1)
  *	    scheduler patch
+ * 06/04/05 Cache hints added:
+ *	    For loads before the atomic operations:
+ *		"bias" is a hint to acquire exclusive ownership.
+ *		"nta" is a hint to allocate the cache line only in L2
+ *		and to bias it to be replaced.
+ *	    For the atomic operations (as they are handled exclusively by L2):
+ *		"nta" is a hint not to allocate the cache line else than in L2,
+ *		to bias it to be replaced and not to write it back into L3.
+ *	    Added full fencing semantics to the atomic bit operations returning
+ *	    values.
+ *	    Note that it is a temporary solution while we are waiting for explicitly
+ *	    indicated fencing behavior, e.g.:
+ *			test_and_set_bit (int nr, void *addr, MODE_BARRIER)
  */
 
 #include <linux/compiler.h>
@@ -42,9 +55,9 @@ set_bit (int nr, volatile void *addr)
 	bit = 1 << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old | bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 }
 
 /**
@@ -89,9 +102,9 @@ clear_bit (int nr, volatile void *addr)
 	mask = ~(1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old & mask;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 }
 
 /**
@@ -100,14 +113,12 @@ clear_bit (int nr, volatile void *addr)
 static __inline__ void
 __clear_bit (int nr, volatile void *addr)
 {
-	volatile __u32 *p = (__u32 *) addr + (nr >> 5);
-	__u32 m = 1 << (nr & 31);
-	*p &= ~m;
+	*((__u32 *) addr + (nr >> 5)) &= ~(1 << (nr & 31));
 }
 
 /**
  * change_bit - Toggle a bit in memory
- * @nr: Bit to clear
+ * @nr: Bit to change
  * @addr: Address to start counting from
  *
  * change_bit() is atomic and may not be reordered.
@@ -122,17 +133,17 @@ change_bit (int nr, volatile void *addr)
 	CMPXCHG_BUGCHECK_DECL
 
 	m = (volatile __u32 *) addr + (nr >> 5);
-	bit = (1 << (nr & 31));
+	bit = 1 << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old ^ bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 }
 
 /**
  * __change_bit - Toggle a bit in memory
- * @nr: the bit to set
+ * @nr: the bit to change
  * @addr: the address to start counting from
  *
  * Unlike change_bit(), this function is non-atomic and may be reordered.
@@ -160,13 +171,14 @@ test_and_set_bit (int nr, volatile void 
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = 1 << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old | bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 	return (old & bit) != 0;
 }
 
@@ -192,7 +204,7 @@ __test_and_set_bit (int nr, volatile voi
 
 /**
  * test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to clear
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
@@ -205,19 +217,20 @@ test_and_clear_bit (int nr, volatile voi
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	mask = ~(1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old & mask;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 	return (old & ~mask) != 0;
 }
 
 /**
  * __test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to clear
  * @addr: Address to count from
  *
  * This operation is non-atomic and can be reordered.  
@@ -237,7 +250,7 @@ __test_and_clear_bit(int nr, volatile vo
 
 /**
  * test_and_change_bit - Change a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to change
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
@@ -250,13 +263,14 @@ test_and_change_bit (int nr, volatile vo
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = (1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		old = ia64_ld4_bias_nta(m);
 		new = old ^ bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 	return (old & bit) != 0;
 }
 
--- old/include/asm-ia64/gcc_intrin.h	2006-04-04 18:19:50.000000000 +0200
+++ linux-2.6.16/include/asm-ia64/gcc_intrin.h	2006-04-05 17:07:29.000000000 +0200
@@ -221,6 +221,14 @@ register unsigned long ia64_r13 asm ("r1
 	asm volatile ("stf.spill [%0]=%1" :: "r"(x), "f"(__f__) : "memory");	\
 })
 
+#define ia64_ld4_bias_nta(ptr)							\
+({										\
+	__u32 ia64_intri_res;							\
+	asm volatile ("ld4.bias.nta %0=[%1]":					\
+			      "=r"(ia64_intri_res) : "r"(ptr) : "memory");	\
+	ia64_intri_res;								\
+})
+
 #define ia64_fetchadd4_acq(p, inc)						\
 ({										\
 										\
@@ -350,6 +358,15 @@ register unsigned long ia64_r13 asm ("r1
 	ia64_intri_res;									\
 })
 
+#define ia64_cmpxchg4_acq_nta(ptr, new, old)						\
+({											\
+	__u32 ia64_intri_res;								\
+	asm volatile ("mov ar.ccv=%0;;" :: "rO"(old));					\
+	asm volatile ("cmpxchg4.acq.nta %0=[%1],%2,ar.ccv":				\
+			      "=r"(ia64_intri_res) : "r"(ptr), "r"(new) : "memory");	\
+	ia64_intri_res;									\
+})
+
 #define ia64_cmpxchg8_acq(ptr, new, old)						\
 ({											\
 	__u64 ia64_intri_res;								\

--------------010503030109080003070501--
