From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Feb 2004 03:53:34 +0000
Subject: Re: Important NaT-bit bug fix
Message-Id: <16445.28094.85163.483336@napali.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="3speOJ5Ml5"
List-Id: <linux-ia64.vger.kernel.org>
References: <16445.8557.274484.443935@napali.hpl.hp.com>
In-Reply-To: <16445.8557.274484.443935@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org


--3speOJ5Ml5
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

>>>>> On Thu, 26 Feb 2004 03:27:04 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> Hi David, I only see the 2.6.3 patch attached; could you
  Matthew> send the 2.4 version please?

Oops, sorry about that.

	--david


--3speOJ5Ml5
Content-Type: text/plain
Content-Description: 2.4.diff
Content-Disposition: inline;
	filename="2.4-sigcontext-nat-fix.diff"
Content-Transfer-Encoding: 7bit

===== arch/ia64/kernel/ptrace.c 1.18 vs edited =====
--- 1.18/arch/ia64/kernel/ptrace.c	Wed Jul 30 06:33:09 2003
+++ edited/arch/ia64/kernel/ptrace.c	Wed Feb 25 14:14:28 2004
@@ -63,12 +63,25 @@
 	({										\
 		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
 		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
-		(ia64_rotl(unat, first) >> bit) & mask;					\
+		unsigned long dist;							\
+		if (bit < first)							\
+			dist = 64 + bit - first;					\
+		else									\
+			dist = bit - first;						\
+		ia64_rotr(unat, dist) & mask;						\
 	})
 	unsigned long val;
 
-	val  = GET_BITS( 1,  3, scratch_unat);
-	val |= GET_BITS(12, 15, scratch_unat);
+	/*
+	 * Registers that are stored consecutively in struct pt_regs can be handled in
+	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
+	 * updated.
+	 */
+	val  = GET_BITS( 1,  1, scratch_unat);
+	val |= GET_BITS( 2,  3, scratch_unat);
+	val |= GET_BITS(12, 13, scratch_unat);
+	val |= GET_BITS(14, 14, scratch_unat);
+	val |= GET_BITS(15, 15, scratch_unat);
 	val |= GET_BITS( 8, 11, scratch_unat);
 	val |= GET_BITS(16, 31, scratch_unat);
 	return val;
@@ -84,16 +97,29 @@
 unsigned long
 ia64_put_scratch_nat_bits (struct pt_regs *pt, unsigned long nat)
 {
+#	define PUT_BITS(first, last, nat)						\
+	({										\
+		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
+		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
+		long dist;								\
+		if (bit < first)							\
+			dist = 64 + bit - first;					\
+		else									\
+			dist = bit - first;						\
+		ia64_rotl(nat & mask, dist);						\
+	})
 	unsigned long scratch_unat;
 
-#	define PUT_BITS(first, last, nat)					\
-	({									\
-		unsigned long bit = ia64_unat_pos(&pt->r##first);		\
-		unsigned long mask = ((1UL << (last - first + 1)) - 1) << bit;	\
-		(ia64_rotr(nat, first) << bit) & mask;				\
-	})
-	scratch_unat  = PUT_BITS( 1,  3, nat);
-	scratch_unat |= PUT_BITS(12, 15, nat);
+	/*
+	 * Registers that are stored consecutively in struct pt_regs can be handled in
+	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
+	 * updated.
+	 */
+	scratch_unat  = PUT_BITS( 1,  1, nat);
+	scratch_unat |= PUT_BITS( 2,  3, nat);
+	scratch_unat |= PUT_BITS(12, 13, nat);
+	scratch_unat |= PUT_BITS(14, 14, nat);
+	scratch_unat |= PUT_BITS(15, 15, nat);
 	scratch_unat |= PUT_BITS( 8, 11, nat);
 	scratch_unat |= PUT_BITS(16, 31, nat);
 
===== include/asm-ia64/processor.h 1.30 vs edited =====
--- 1.30/include/asm-ia64/processor.h	Thu Jan 22 10:32:17 2004
+++ edited/include/asm-ia64/processor.h	Wed Feb 25 14:15:34 2004
@@ -927,24 +927,13 @@
 	return retval;
 }
 
-/* XXX remove the handcoded version once we have a sufficiently clever compiler... */
-#ifdef SMART_COMPILER
-# define ia64_rotr(w,n)				\
-  ({						\
-	__u64 _w = (w), _n = (n);		\
-						\
-	(_w >> _n) | (_w << (64 - _n));		\
-  })
-#else
-# define ia64_rotr(w,n)							\
-  ({									\
-	__u64 result;							\
-	asm ("shrp %0=%1,%1,%2" : "=r"(result) : "r"(w), "i"(n));	\
-	result;								\
-  })
-#endif
+static inline __u64
+ia64_rotr (__u64 w, __u64 n)
+{
+	return (w >> n) | (w << (64 - n));
+}
 
-#define ia64_rotl(w,n)	ia64_rotr((w),(64)-(n))
+#define ia64_rotl(w,n)	ia64_rotr((w), (64) - (n))
 
 static inline __u64
 ia64_thash (__u64 addr)

--3speOJ5Ml5--
