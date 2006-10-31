From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Oct 2006 08:09:18 +0000
Subject: RE: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <000201c6fcc3$dd5e60d0$5181030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote on Monday, October 30, 2006 10:18 PM
> >+GLOBAL_ENTRY(kprobe_update_inst_bundle)
> >+	alloc loc0=ar.pfs,3,1,0,0
> >+
> >+	and r15,r34
> >+	and r14,r33
> 
> Use in0, in1, in2, not r32-34.

Also there is no need to resize the register stack frame here, since
this is already a leaf function and there are plenty scratch register
you can use before tap into register stack.  I personally prefer not
to do alloc instruction here.

And I think it would be a lot easier if you implement an intrinsic
function, like ia64_ld16/ia64_st16 and stick them in include/asm-ia64/
gcc_intrin.h and intel_intrin.h.
