From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 24 Jul 2001 03:02:02 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.7)
Message-Id: <marc-linux-ia64-105590693005890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jul 2001 16:49:32 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The latest IA-64 patch is available at:
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
>in file linux-2.4.7-ia64-010723.diff*.

2.4.7 has __set_bit and similar functions, used by devfs, there is no
IA64 implementation.  Most of the patch is adding DocBook headers.

Index: 7.11/include/asm-ia64/bitops.h
--- 7.11/include/asm-ia64/bitops.h Tue, 24 Jul 2001 11:08:09 +1000 kaos (linux-2.4/t/47_bitops.h 1.1.3.1.1.1 644)
+++ 7.11(w)/include/asm-ia64/bitops.h Tue, 24 Jul 2001 12:47:45 +1000 kaos (linux-2.4/t/47_bitops.h 1.1.3.1.1.1 644)
@@ -10,15 +10,23 @@
 
 #include <asm/system.h>
 
-/*
- * These operations need to be atomic.  The address must be (at least) "long" aligned.
+/**
+ * set_bit - Atomically set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * This function is atomic and may not be reordered.  See __set_bit()
+ * if you do not require the atomic guarantees.
+ * Note that @nr may be almost arbitrarily large; this function is not
+ * restricted to acting on a single-word quantity.
+ *
+ * The address must be (at least) "long" aligned.
  * Note that there are driver (e.g., eepro100) which use these operations to operate on
  * hw-defined data-structures, so we can't easily change these operations to force a
  * bigger alignment.
  *
  * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
  */
-
 static __inline__ void
 set_bit (int nr, volatile void *addr)
 {
@@ -35,11 +43,36 @@ set_bit (int nr, volatile void *addr)
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
+/**
+ * __set_bit - Set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike set_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static __inline__ void __set_bit(int nr, volatile void * addr)
+{
+	*((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
+}
+
 /*
  * clear_bit() doesn't provide any barrier for the compiler.
  */
 #define smp_mb__before_clear_bit()	smp_mb()
 #define smp_mb__after_clear_bit()	smp_mb()
+
+/**
+ * clear_bit - Clears a bit in memory
+ * @nr: Bit to clear
+ * @addr: Address to start counting from
+ *
+ * clear_bit() is atomic and may not be reordered.  However, it does
+ * not contain a memory barrier, so if it is used for locking purposes,
+ * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
+ * in order to ensure changes are visible on other processors.
+ */
 static __inline__ void
 clear_bit (int nr, volatile void *addr)
 {
@@ -56,18 +89,29 @@ clear_bit (int nr, volatile void *addr)
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
-/*
- * WARNING: non atomic version.
+/**
+ * __change_bit - Toggle a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike change_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
  */
-static __inline__ void
-__change_bit (int nr, void *addr)
+static __inline__ void __change_bit(int nr, volatile void * addr)
 {
-	volatile __u32 *m = (__u32 *) addr + (nr >> 5);
-	__u32 bit = (1 << (nr & 31));
-
-	*m = *m ^ bit;
+	*((__u32 *) addr + (nr >> 5)) ^= (1 << (nr & 31));
 }
 
+/**
+ * change_bit - Toggle a bit in memory
+ * @nr: Bit to clear
+ * @addr: Address to start counting from
+ *
+ * change_bit() is atomic and may not be reordered.
+ * Note that @nr may be almost arbitrarily large; this function is not
+ * restricted to acting on a single-word quantity.
+ */
 static __inline__ void
 change_bit (int nr, volatile void *addr)
 {
@@ -84,6 +128,14 @@ change_bit (int nr, volatile void *addr)
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
+/**
+ * test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is atomic and cannot be reordered.  
+ * It also implies a memory barrier.
+ */
 static __inline__ int
 test_and_set_bit (int nr, volatile void *addr)
 {
@@ -101,6 +153,30 @@ test_and_set_bit (int nr, volatile void 
 	return (old & bit) != 0;
 }
 
+/**
+ * __test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.  
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static __inline__ int __test_and_set_bit(int nr, volatile void * addr)
+{
+	int oldbit = *((__u32 *) addr + (nr >> 5)) & (1 << (nr & 31));
+	*((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
+	return(oldbit != 0);
+}
+
+/**
+ * test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is atomic and cannot be reordered.  
+ * It also implies a memory barrier.
+ */
 static __inline__ int
 test_and_clear_bit (int nr, volatile void *addr)
 {
@@ -118,6 +194,22 @@ test_and_clear_bit (int nr, volatile voi
 	return (old & ~mask) != 0;
 }
 
+/**
+ * __test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.  
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static __inline__ int __test_and_clear_bit(int nr, volatile void * addr)
+{
+	int oldbit = *((__u32 *) addr + (nr >> 5)) & (1 << (nr & 31));
+	*((__u32 *) addr + (nr >> 5)) &= ~(1 << (nr & 31));
+	return(oldbit != 0);
+}
+
 /*
  * WARNING: non atomic version.
  */
@@ -132,6 +224,14 @@ __test_and_change_bit (int nr, void *add
 	return (old & bit) != 0;
 }
 
+/**
+ * test_and_change_bit - Change a bit and return its new value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is atomic and cannot be reordered.  
+ * It also implies a memory barrier.
+ */
 static __inline__ int
 test_and_change_bit (int nr, volatile void *addr)
 {
@@ -155,10 +255,13 @@ test_bit (int nr, volatile void *addr)
 	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
 }
 
-/*
- * ffz = "find first zero".  Returns the bit number (0..63) of the first (least
- * significant) bit that is zero in X.  Undefined if no zero exists, so code should check
- * against ~0UL first...
+/**
+ * find_first_zero_bit - find the first zero bit in a memory region
+ * @x: The address to start the search at
+ *
+ * Returns the bit-number (0..63) of the first (least significant) zero bit, not
+ * the number of the byte containing a bit.  Undefined if no zero exists, so
+ * code should check against ~0UL first...
  */
 static inline unsigned long
 ffz (unsigned long x)
@@ -172,8 +275,8 @@ ffz (unsigned long x)
 #ifdef __KERNEL__
 
 /*
- * Find the most significant bit that is set (undefined if no bit is
- * set).
+ * find_last_zero_bit - find the last zero bit in a 64 bit quantity
+ * @x: The value to search
  */
 static inline unsigned long
 ia64_fls (unsigned long x)


