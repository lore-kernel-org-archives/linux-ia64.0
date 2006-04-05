From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 05 Apr 2006 16:44:19 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning
Message-Id: <4433F3E3.6080403@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040605050508090901080704"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040605050508090901080704
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Christoph Lameter wrote:

> Could decomplicate this? Just use acquire / release and avoid the 
> additional intrinsics. The purpose is first of all correctness. Then we 
> can add some whiz bang on top. Also please sent patches inline not as 
> attachments.

I could have misunderstood what you wrote yesterday:

>>Could you consider using some cache hints, like "ld8.bias.nta"?
>>"bias" is a hint to acquire exclusive ownership.
>>"nta" is a hint to allocate the cache line only in L2
>>(and side effect: to bias it to be replaced).
>>All of the Itanium 2 processor's atomic instructions are handled
>>exclusively by the L2 cache.
> 
> Could you come up with a patch? Currently, I do not seem to be able to 
> spend enough time on it.

I thought you had asked for both the correct fencing and the cache hints.

Thanks,

Zoltan


--------------040605050508090901080704
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="bitops.diff"
Content-Disposition: inline;
 filename="bitops.diff"

--- old/include/asm-ia64/bitops.h	2006-04-04 18:19:50.000000000 +0200
+++ linux-2.6.16/include/asm-ia64/bitops.h	2006-04-05 18:38:44.000000000 +0200
@@ -7,6 +7,11 @@
  *
  * 02/06/02 find_next_bit() and find_first_bit() added from Erich Focht's ia64 O(1)
  *	    scheduler patch
+ * 06/04/05 Added full fencing semantics to the atomic bit operations returning
+ *	    values.
+ *	    Note that it is a temporary solution while we are waiting for explicitly
+ *	    indicated fencing behavior, e.g.:
+ *			test_and_set_bit (int nr, void *addr, MODE_BARRIER)
  */
 
 #include <linux/compiler.h>
@@ -160,6 +165,7 @@ test_and_set_bit (int nr, volatile void 
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = 1 << (nr & 31);
 	do {
@@ -192,7 +198,7 @@ __test_and_set_bit (int nr, volatile voi
 
 /**
  * test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to clear
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
@@ -205,6 +211,7 @@ test_and_clear_bit (int nr, volatile voi
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	mask = ~(1 << (nr & 31));
 	do {
@@ -237,7 +244,7 @@ __test_and_clear_bit(int nr, volatile vo
 
 /**
  * test_and_change_bit - Change a bit and return its old value
- * @nr: Bit to set
+ * @nr: Bit to change
  * @addr: Address to count from
  *
  * This operation is atomic and cannot be reordered.  
@@ -250,6 +257,7 @@ test_and_change_bit (int nr, volatile vo
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	ia64_mf();
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = (1 << (nr & 31));
 	do {

--------------040605050508090901080704--
