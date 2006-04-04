From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 04 Apr 2006 16:48:36 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning
Message-Id: <4432A364.7020607@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050305030503000600030606"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050305030503000600030606
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

Christoph Lameter wrote:

> Could you come up with a patch? Currently, I do not seem to be able to 
> spend enough time on it.

Please have a look at this sample.

Temporary solution while we are waiting for:

	test_and_set_bit (int nr, volatile void *addr, MODE_BARRIER)

& co.

I changed the temp. variables to be 64 bit wide in order to eliminate a "zxt4".

Here is what I get (NOP-s removed):

<reserve_bootmem_core+240>:  [MMI]       mf;;
<reserve_bootmem_core+241>:              and r10=31,r18
<reserve_bootmem_core+257>:              extr r11=r18,5,27;;
<reserve_bootmem_core+272>:  [MFI]       shladd r16=r11,2,r16
<reserve_bootmem_core+274>:              shl r17=r19,r10;;
<reserve_bootmem_core+288>:  [MMI]       ld4.bias.nta r20=[r16];;
<reserve_bootmem_core+289>:              or r22=r17,r20
<reserve_bootmem_core+305>:              mov.m ar.ccv=r20;;
<reserve_bootmem_core+320>:  [MMI]       cmpxchg4.acq.nta r21=[r16],r22,ar.ccv;;
<reserve_bootmem_core+322>:              cmp.eq p14,p15=r20,r21
<reserve_bootmem_core+336>:  [BBB] (p15) br.cond.dptk.few <reserve_bootmem_core+288>

Notes:

"reserve_bootmem_core()" is a typical example of unnecessary fencing.

What a nasty business reversing the "old" vs. "new" parameters:

#define ia64_cmpxchg(sem,ptr,old,new,size)
...
	      	_r_ = ia64_cmpxchg1_##sem((__u8 *) ptr, new, _o_);

--------------050305030503000600030606
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
 name="diff"
Content-Disposition: inline;
 filename="diff"

--- old/include/asm-ia64/bitops.h	2006-04-04 18:19:50.000000000 +0200
+++ linux-2.6.16-ccb/include/asm-ia64/bitops.h	2006-04-04 18:17:26.000000000 +0200
@@ -154,19 +154,32 @@ __change_bit (int nr, volatile void *add
  * It also implies a memory barrier.
  */
 static __inline__ int
-test_and_set_bit (int nr, volatile void *addr)
+test_and_set_bit (int nr, void *addr)
 {
-	__u32 bit, old, new;
-	volatile __u32 *m;
+	__u64 bit, old, new;
+	__u64 *m;
 	CMPXCHG_BUGCHECK_DECL
 
-	m = (volatile __u32 *) addr + (nr >> 5);
-	bit = 1 << (nr & 31);
+	ia64_mf();
+	m = (__u64 *)((__u32 *) addr + (nr >> 5));
+	bit = 1UL << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
-		old = *m;
+		/*
+		 * "bias" is a hint to acquire exclusive ownership.
+		 * "nta" is a hint to allocate the cache line only in L2
+		 * and to bias it to be replaced.
+		 */
+		old = ia64_ld4_bias_nta(m);
 		new = old | bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+		/*
+		 * All of the Itanium 2 processor's atomic instructions
+		 * are handled exclusively by L2.
+		 * "nta" is a hint not to allocate the cache line else
+		 * than in L2, to bias it to be replaced and not to write
+		 * it back into L3.
+		 */
+	} while (ia64_cmpxchg4_acq_nta(m, new, old) != old);
 	return (old & bit) != 0;
 }
 
--- old/include/asm-ia64/gcc_intrin.h	2006-04-04 18:19:50.000000000 +0200
+++ linux-2.6.16-ccb/include/asm-ia64/gcc_intrin.h	2006-04-04 18:17:49.000000000 +0200
@@ -221,6 +221,14 @@ register unsigned long ia64_r13 asm ("r1
 	asm volatile ("stf.spill [%0]=%1" :: "r"(x), "f"(__f__) : "memory");	\
 })
 
+#define ia64_ld4_bias_nta(ptr)							\
+({										\
+	__u64 ia64_intri_res;							\
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
+	__u64 ia64_intri_res;								\
+	asm volatile ("mov ar.ccv=%0;;" :: "rO"(old));					\
+	asm volatile ("cmpxchg4.acq.nta %0=[%1],%2,ar.ccv":				\
+			      "=r"(ia64_intri_res) : "r"(ptr), "r"(new) : "memory");	\
+	ia64_intri_res;									\
+})
+
 #define ia64_cmpxchg8_acq(ptr, new, old)						\
 ({											\
 	__u64 ia64_intri_res;								\

--------------050305030503000600030606--
