From: Andrew Morton <akpm@osdl.org>
Date: Tue, 02 Nov 2004 03:28:22 +0000
Subject: Re: [PATCH] IA64 build broken... cond_syscall()... Fixes?
Message-Id: <20041101201808.58a559a5.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411020239.iA22dsQl026520@mail23.syd.optusnet.com.au>
In-Reply-To: <200411020239.iA22dsQl026520@mail23.syd.optusnet.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
>
> 
> Hi Folks,
>    The kernel 2.6 IA64 build has been broken for several days (see
> http://www.gelato.unsw.edu.au/kerncomp )
> 
> The reason is that cond_syscall() for IA64 is defined as:
> 
>   #define cond_syscall(x) asmlinkage long x (void) \
> 	__attribute__((weak,alias("sys_ni_syscall")))   
> 
> which of course doesn't work if there's a prototype in scope for x,
> unless the type of x just happens to be the same as for sys_ni_syscall.
> 
> Changing to the type-safe version
>    #define cond_syscall(x) __typeof__ (x) x \
> 	   __attribute__((weak,alias("sys_ni_syscall")));
> gives an error, e.g., 
>  error: `compat_sys_futex' defined both normally and as an alias

Yeah, it's a real bitch, that.

> Most architectures use inline assembly language which avoids the
> problem.  However, we don't want to do this for IA64, to allow
> compilers other than gcc to be used (in general, gcc generated code
> for IA64 is extremely poor).
> 
> There are several ways to fix this.  The simple way is to ensure that
> there are no prototypes for any system calls included in kernel/sys.c
> (the only place where cond_syscall is used).  That's what this patch
> does:

But I bet it introduces various nasty warnings or type-unsafety on other
architectures.

Shouldn't we just bite the bullet and hoist all that cond_syscall stuff out
into its own .c file?
