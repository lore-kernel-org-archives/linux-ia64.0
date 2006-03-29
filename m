From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 01:06:25 +0000
Subject: Cleanup non-atomic bit operation
Message-Id: <200603290105.k2T15ng00381@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Non-atomic version of __clear_bit uses volatile declaration, which turned
into an expensive ordered operation.  Fixed that up.  Also fix up cosmetic
function declaration for other non-atomic bit ops.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./include/asm-ia64/bitops.h.orig	2006-03-28 17:53:48.000000000 -0800
+++ ./include/asm-ia64/bitops.h	2006-03-28 17:57:45.000000000 -0800
@@ -57,7 +57,7 @@ set_bit (int nr, volatile void *addr)
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__set_bit (int nr, volatile void *addr)
+__set_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
 }
@@ -98,11 +98,9 @@ clear_bit (int nr, volatile void *addr)
  * __clear_bit - Clears a bit in memory (non-atomic version)
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
@@ -140,7 +138,7 @@ change_bit (int nr, volatile void *addr)
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__change_bit (int nr, volatile void *addr)
+__change_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) ^= (1 << (nr & 31));
 }
@@ -180,7 +178,7 @@ test_and_set_bit (int nr, volatile void 
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_set_bit (int nr, volatile void *addr)
+__test_and_set_bit (int nr, void *addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
@@ -225,7 +223,7 @@ test_and_clear_bit (int nr, volatile voi
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_clear_bit(int nr, volatile void * addr)
+__test_and_clear_bit(int nr, void * addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);

