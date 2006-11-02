From: Keith Owens <kaos@sgi.com>
Date: Thu, 02 Nov 2006 03:39:50 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <19255.1162438790@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"bibo,mao" (on Thu, 02 Nov 2006 11:11:42 +0800) wrote:
>+#define ia64_ld16(low, addr)						\
>+	asm volatile(";;ld16 %0=[%1];;":"=r"(low):"r"(addr):"memory")
>+#define ia64_st16(low, addr)						\
>+	asm volatile(";;st16 [%1]=%0;;"::"r"(low),"r"(addr):"memory")
>...
>+#define ia64_st16(low, addr)    __st16(__sttype_none, __sthint_none, addr, low)
>+#define ia64_ld16(low, addr)					\
>+  	low =  __ld16(__ldtype_none, __ldtype_none, addr)
>+

ld16 clobbers ar.csd, that needs to be added to the definition of
ia64_ld16.

ia64_ld16 does not need a memory clobber.

Strictly speaking, ia64_st16 does not need a memory clobber.  addr
should be a write operand (not read as you have it) and gcc should see
that addr is clobbered.  However we clobber 16 bytes starting at addr
and I suspect that gcc has no way of telling about the second set of 8
bytes.  In this case, we may have to stick with a memory clobber on
ia64_st16.

>+#define kprobe_update_bundle(dest, src)		\
>+do {						\
>+	unsigned long low;			\
>+	ia64_ld16(low, src);			\
>+	ia64_st16(low, dest);			\
>+} while (0)

Using unsigned long (8 bytes) is misleading for a 16 byte operation.
Not sure what we can do about that.

