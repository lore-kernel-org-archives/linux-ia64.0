From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Oct 2006 08:40:46 +0000
Subject: RE: [PATCH] IA64 trap code 16 bytes atomic copy on montecito
Message-Id: <000301c6fcc8$4899de20$5181030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546E55E.3050207@intel.com>
In-Reply-To: <4546E55E.3050207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mao, Bibo wrote on Tuesday, October 31, 2006 12:19 AM
> > Also there is no need to resize the register stack frame here, since
> > this is already a leaf function and there are plenty scratch register
> > you can use before tap into register stack.  I personally prefer not
> > to do alloc instruction here.
> > 
> > And I think it would be a lot easier if you implement an intrinsic
> > function, like ia64_ld16/ia64_st16 and stick them in include/asm-ia64/
> > gcc_intrin.h and intel_intrin.h.
> > 
> 
> but there will be inline asm in c language, it is not benefit for gcc to
> optimization, I hear that IA64 hates inline asm.

We hate style like:

void foo()
{
	int a;

	blah()

	asm("ld16 ..." :: "" ..."");

	bar();
}

Because this breaks all icc builds.  It's perfectly fine to add an
abstraction function that turns the above asm("") into ia64_ld16(). For
gcc, it expands into an inline asm. For icc, it turns into an intrinsic.

In fact, for a simple case like ld16 instruction, it is better to use
intrinsic (or gcc asm with appropriate clobber list) because using a
function call will pretty much destroy all high level optimization
around that call. Just imagine all of intermediate value stored in
scratch registers before the call all become void after the call. With
asm/intrinsic, the compiler has more knowledge to what's going on and
can do a better job at it.


