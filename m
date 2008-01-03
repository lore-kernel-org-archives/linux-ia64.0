From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 03 Jan 2008 13:36:08 +0000
Subject: Re: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <477CE4C8.4000807@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090209050408060903070102"
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090209050408060903070102
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Please have a look at the patch below.

Taking this opportunity, in addition:
- I removed the useless "volatile" stuff from the non-atomic versions
  of the bit operations.
- I removed the unnecessary barrier() from __clear_bit_unlock().
  ia64_st4_rel_nta() makes sure all the modifications are globally
  seen before the bit is seen to be off.
- I made __clear_bit() modeled after __set_bit() and __change_bit().
- I corrected some comments sating that a memory barrier is provided,
  yet in reality, it is the acquisition side of the memory barrier only.
- I corrected some comments, e.g. test_and_clear_bit() was peaking
  about "bit to set".

Signed-off-by: Zoltan Menyhart, <Zoltan.Menyhart@bull.net>

Thanks,

Zoltan Menyhart


--------------090209050408060903070102
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

--- include/asm/bitops.h-old	2007-12-21 02:25:48.000000000 +0100
+++ include/asm/bitops.h	2008-01-03 14:25:17.000000000 +0100
@@ -60,7 +60,7 @@
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__set_bit (int nr, volatile void *addr)
+__set_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
 }
@@ -122,38 +122,40 @@
 }
 
 /**
- * __clear_bit_unlock - Non-atomically clear a bit with release
+ * __clear_bit_unlock - Non-atomically clears a bit in memory with release
+ * @nr: Bit to clear
+ * @addr: Address to start counting from
  *
- * This is like clear_bit_unlock, but the implementation uses a store
+ * Similarly to clear_bit_unlock, the implementation uses a store
  * with release semantics. See also __raw_spin_unlock().
  */
 static __inline__ void
-__clear_bit_unlock(int nr, volatile void *addr)
+__clear_bit_unlock(int nr, void *addr)
 {
-	__u32 mask, new;
-	volatile __u32 *m;
+	__u32 * const m = (__u32 *) addr + (nr >> 5);
+	__u32 const new = *m & ~(1 << (nr & 31));
 
-	m = (volatile __u32 *)addr + (nr >> 5);
-	mask = ~(1 << (nr & 31));
-	new = *m & mask;
-	barrier();
 	ia64_st4_rel_nta(m, new);
 }
 
 /**
  * __clear_bit - Clears a bit in memory (non-atomic version)
+ * @nr: the bit to clear
+ * @addr: the address to start counting from
+ *
+ * Unlike clear_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
  */
 static __inline__ void
-__clear_bit (int nr, volatile void *addr)
+__clear_bit (int nr, void *addr)
 {
-	volatile __u32 *p = (__u32 *) addr + (nr >> 5);
-	__u32 m = 1 << (nr & 31);
-	*p &= ~m;
+	*((__u32 *) addr + (nr >> 5)) &= ~(1 << (nr & 31));
 }
 
 /**
  * change_bit - Toggle a bit in memory
- * @nr: Bit to clear
+ * @nr: Bit to toggle
  * @addr: Address to start counting from
  *
  * change_bit() is atomic and may not be reordered.
@@ -178,7 +180,7 @@
 
 /**
  * __change_bit - Toggle a bit in memory
- * @nr: the bit to set
+ * @nr: the bit to toggle
  * @addr: the address to start counting from
  *
  * Unlike change_bit(), this function is non-atomic and may be reordered.
@@ -186,7 +188,7 @@
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__change_bit (int nr, volatile void *addr)
+__change_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) ^= (1 << (nr & 31));
 }
@@ -197,7 +199,7 @@
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
- * It also implies a memory barrier.
+ * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
 test_and_set_bit (int nr, volatile void *addr)
@@ -235,7 +237,7 @@
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_set_bit (int nr, volatile void *addr)
+__test_and_set_bit (int nr, void *addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
@@ -247,11 +249,11 @@
 
 /**
  * test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to clear
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
- * It also implies a memory barrier.
+ * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
 test_and_clear_bit (int nr, volatile void *addr)
@@ -272,7 +274,7 @@
 
 /**
  * __test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to clear
  * @addr: Address to count from
  *
  * This operation is non-atomic and can be reordered.  
@@ -280,7 +282,7 @@
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_clear_bit(int nr, volatile void * addr)
+__test_and_clear_bit(int nr, void * addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
@@ -292,11 +294,11 @@
 
 /**
  * test_and_change_bit - Change a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to change
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
- * It also implies a memory barrier.
+ * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
 test_and_change_bit (int nr, volatile void *addr)
@@ -315,8 +317,12 @@
 	return (old & bit) != 0;
 }
 
-/*
- * WARNING: non atomic version.
+/**
+ * __test_and_change_bit - Change a bit and return its old value
+ * @nr: Bit to change
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
  */
 static __inline__ int
 __test_and_change_bit (int nr, void *addr)

--------------090209050408060903070102--
