From: Matthew Wilcox <willy@debian.org>
Date: Thu, 26 Feb 2004 21:16:15 +0000
Subject: Re: Important NaT-bit bug fix
Message-Id: <20040226211614.GV25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16445.8557.274484.443935@napali.hpl.hp.com>
In-Reply-To: <16445.8557.274484.443935@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 25, 2004 at 02:27:57PM -0800, David Mosberger wrote:
> NOTE TO USERS/DISTRIBUTORS OF OLDER KERNELS: if you do NOT have the
> streamlined syscall-path patch applied in your kernel, then the patch
> needs to be modified such that in ia64_{get,put}_scratch_nat_bits()
> only the GET_BITS/PUT_BITS macros are changed (the rest should remain
> the same).  If in doubt, run the attached test program below.

Code is clearer than words.  Can you verify the following patch is what
you meant by the above?  Having looked at the documentation for the unat
bit, I think this is right, but it's complicated for someone coming to
it for the first time.

--- 1.18/arch/ia64/kernel/ptrace.c	Wed Jul 30 06:33:09 2003
+++ edited/arch/ia64/kernel/ptrace.c	Wed Feb 25 14:14:28 2004
@@ -63,7 +63,12 @@
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
 
@@ -84,14 +97,19 @@
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
 	scratch_unat  = PUT_BITS( 1,  3, nat);
 	scratch_unat |= PUT_BITS(12, 15, nat);
 	scratch_unat |= PUT_BITS( 8, 11, nat);
=== include/asm-ia64/processor.h 1.30 vs edited ==--- 1.30/include/asm-ia64/processor.h	Thu Jan 22 10:32:17 2004
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

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
