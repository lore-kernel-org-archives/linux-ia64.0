From: Jack Steiner <steiner@sgi.com>
Date: Thu, 13 Jun 2002 18:14:52 +0000
Subject: Re: [Linux-ia64] pthread failure ???
Message-Id: <marc-linux-ia64-105590701905671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Wed, 12 Jun 2002 19:56:50 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> We have a pthread'ed application that ran fine on IA64 2.4.17.
> 
>   Jack> When we upgraded the kernel to 2.4.18, the application started
>   Jack> to fail. The failure occurs in glibc at: chunk_free
>   Jack> __libc_free ...
> 
>   Jack> We verified that the app consistently fails with a 2.4.18
>   Jack> kernel but works fine with a 2.4.17 kernel (same app &
>   Jack> libraries).
> 
>   Jack> No other failures have been seen in other apps.
> 
>   Jack> Has anyone else seen this behavior or have any ideas??
> 
> I'm wondering if this is related to the fix for the "sp off by 16" bug
> that was introduced in the 020410 ia64 patch.  The relevant bits are below.
> Can you see if the problem occurs without these changes?



I undid the patch (below). It still fails. Some observations about the failure:

	- the failure is a SEGV. chunk_free tries to dereference a NULL pointer
	  (plus a small offset).

	- the failure appears to occur at the end of the test when the control process
	  is killing off child threads and freeing up structure allocated from
	  the heap.

	- gdb is not helpful on the core file. However, I hacked the kernel to
	  drop to KDB on SEGV & dumpped registers that way.

	- the program runs fine when launched from gdb.

	- the address of pthread_testcancel() is frequently seen around the point of 
	  failure. I dont know if that is significant or not.

	- we are using a 2.4.18 (ia64 020410) kernel with glibc-2.2.3-10




I certainly dont rule out bugs in the app. 


> 
> 	--david
> 
> diff -urN linux-2.4.18/arch/ia64/ia32/ia32_entry.S lia64-2.4/arch/ia64/ia32/ia32_entry.S
> --- linux-2.4.18/arch/ia64/ia32/ia32_entry.S	Mon Nov 26 11:18:19 2001
> +++ lia64-2.4/arch/ia64/ia32/ia32_entry.S	Sat Feb  9 10:41:41 2002
> @@ -37,7 +37,7 @@
>  	mov loc1=r16				// save ar.pfs across do_fork
>  	.body
>  	zxt4 out1=in1				// newsp
> -	mov out3=0				// stacksize
> +	mov out3				// stacksize (compensates for 16-byte scratch area)
>  	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
>  	zxt4 out0=in0				// out0 = clone_flags
>  	br.call.sptk.many rp=do_fork
> diff -urN linux-2.4.18/arch/ia64/kernel/entry.S lia64-2.4/arch/ia64/kernel/entry.S
> --- linux-2.4.18/arch/ia64/kernel/entry.S	Mon Nov 26 11:18:20 2001
> +++ lia64-2.4/arch/ia64/kernel/entry.S	Tue Apr  9 22:01:38 2002
> @@ -115,7 +115,7 @@
>  	mov loc1=r16				// save ar.pfs across do_fork
>  	.body
>  	mov out1=in1
> -	mov out3=0
> +	mov out3				// stacksize (compensates for 16-byte scratch area)
>  	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
>  	mov out0=in0				// out0 = clone_flags
>  	br.call.sptk.many rp=do_fork
> diff -urN linux-2.4.18/arch/ia64/kernel/process.c lia64-2.4/arch/ia64/kernel/process.c
> --- linux-2.4.18/arch/ia64/kernel/process.c	Mon Nov 26 11:18:21 2001
> +++ lia64-2.4/arch/ia64/kernel/process.c	Tue Feb 26 14:53:42 2002
> @@ -235,7 +273,7 @@
>  
>  	if (user_mode(child_ptregs)) {
>  		if (user_stack_base) {
> -			child_ptregs->r12 = user_stack_base + user_stack_size;
> +			child_ptregs->r12 = user_stack_base + user_stack_size - 16;
>  			child_ptregs->ar_bspstore = user_stack_base;
>  			child_ptregs->ar_rnat = 0;
>  			child_ptregs->loadrs = 0;
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


