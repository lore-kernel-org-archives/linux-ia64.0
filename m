From: "bibo,mao" <bibo.mao@intel.com>
Date: Tue, 31 Oct 2006 08:19:16 +0000
Subject: Re: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <45470704.8090100@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Keith Owens wrote on Monday, October 30, 2006 10:18 PM
>>> +GLOBAL_ENTRY(kprobe_update_inst_bundle)
>>> +	alloc loc0=ar.pfs,3,1,0,0
>>> +
>>> +	and r15,r34
>>> +	and r14,r33
>> Use in0, in1, in2, not r32-34.
> 
> Also there is no need to resize the register stack frame here, since
> this is already a leaf function and there are plenty scratch register
> you can use before tap into register stack.  I personally prefer not
> to do alloc instruction here.
> 
> And I think it would be a lot easier if you implement an intrinsic
> function, like ia64_ld16/ia64_st16 and stick them in include/asm-ia64/
> gcc_intrin.h and intel_intrin.h.
> 
but there will be inline asm in c language, it is not benefit for gcc to
optimization, I hear that IA64 hates inline asm.

thanks
bibo,mao
