From: Keith Owens <kaos@sgi.com>
Date: Thu, 02 Nov 2006 07:17:57 +0000
Subject: Re: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <22464.1162451877@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"bibo,mao" (on Thu, 02 Nov 2006 14:51:18 +0800) wrote:
>Keith Owens wrote:
>> "bibo,mao" (on Thu, 02 Nov 2006 11:11:42 +0800) wrote:
>>> +#define ia64_ld16(low, addr)						\
>>> +	asm volatile(";;ld16 %0=[%1];;":"=r"(low):"r"(addr):"memory")
>>> +#define ia64_st16(low, addr)						\
>>> +	asm volatile(";;st16 [%1]=%0;;"::"r"(low),"r"(addr):"memory")
>>> ...
>>> +#define ia64_st16(low, addr)    __st16(__sttype_none, __sthint_none, addr, low)
>>> +#define ia64_ld16(low, addr)					\
>>> +  	low =  __ld16(__ldtype_none, __ldtype_none, addr)
>>> +
>> 
>> ld16 clobbers ar.csd, that needs to be added to the definition of
>> ia64_ld16.
>It seems that gcc does not support inline asm clobber for ar.csd register, 
>so here I leave clobber register as empty.

In that case I strongly recommend against using inline asm for ld16 and
st16.  If we cannot tell gcc what the side effects are then inline asm
is not safe.  Use a small assembler function instead, and accept that
we are calling an external function which stops gcc from optimizing
register usage in the C code.

Using a separate assembler function also gets around a dodgy bit of C
code.  Strictly speaking, you should not rely on running two inline asm
statements together, i.e. ia64_ld16() followed by ia64_st16() is not
guaranteed to work.  From 'info gcc':

  "Similarly, you can't expect a sequence of volatile `asm'
  instructions to remain perfectly consecutive.  If you want
  consecutive output, use a single `asm'".

This should do the job.  No prologue or alloc because it is a leaf
function, which means no in0/in1, use r32/r33 instead.

extern ld16_st16(src, dest);

ENTRY(ld16_st16)
	ld16 r15=[r33]		// dest
	;;
	st16 [r32]=r15		// src
	br.ret.sptk.many rp
EXIT(ld16_st16)

