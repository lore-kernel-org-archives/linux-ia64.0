From: Robin Holt <holt@sgi.com>
Date: Tue, 04 May 2010 09:52:57 +0000
Subject: Re: [patch 1/1] ia64 does not pass stack_start != 0 while
Message-Id: <20100504095257.GU4920@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I should have followed up earlier.  In trying to determine what the
"right" behavior was, I determined that there was no consistent behavior
for cases like fork(), pthread followed by fork().  Additionally, it was
pointed out that things like pthread's stack vma's will be merged.  All
these issues combined to force the decision to revert commit d899bf7b55f.

Thanks,
Robin

On Sun, Apr 25, 2010 at 08:06:45AM -0500, holt@sgi.com wrote:
> 
> I had a user report a problem where the /proc/self/stat field 28 is now
> zero where it used to be a value that could be used to determine the
> stack location.  The following illustrates the problem:
> 
> cut -f1,2,28,29 -d\  /proc/[1-9]*/stat | grep -v " 0 0" | grep " 0 "
> 
> Commit d899bf7b55f changed the copy_process in kernel/fork.c to
> expect a useful stack_start value.  I contemplated either using the
> current->mm->start_stack or the ar_bspstore value.  Turns out the
> ar_bspstore value appears to more nearly meet the above commit's intent.
> 
> That said, the above commit has been partially reverted.
> 
> I worked around the problem by passing stack_start with a valid value,
> but setting stack_size to 0.  copy_thread can then key off that changed
> value to retain its old behavior.
> 
> I have modified sys_clone, but I have not verified the values.  The code
> path gets traversed, but none of the tasks calling sys_clone showed up
> in the old trace so I have not verified the values are consistent.
> 
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> To: linux-ia64@vger.kernel.org
> Cc: Jack Steiner <steiner@sgi.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Stefani Seibold <stefani@seibold.net>
> 
> ---
> 
>  arch/ia64/kernel/entry.S   |    8 ++++++++
>  arch/ia64/kernel/process.c |    2 +-
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> Index: ia64_stack_start_V1/arch/ia64/kernel/entry.S
> =================================> --- ia64_stack_start_V1.orig/arch/ia64/kernel/entry.S	2010-04-25 06:45:22.406898052 -0500
> +++ ia64_stack_start_V1/arch/ia64/kernel/entry.S	2010-04-25 06:53:45.575399384 -0500
> @@ -114,15 +114,19 @@ GLOBAL_ENTRY(sys_clone2)
>  	alloc r16=ar.pfs,8,2,6,0
>  	DO_SAVE_SWITCH_STACK
>  	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
> +	adds r3=PT(AR_BSPSTORE)+IA64_SWITCH_STACK_SIZE+16,sp
>  	mov loc0=rp
>  	mov loc1=r16				// save ar.pfs across do_fork
>  	.body
>  	mov out1=in1
>  	mov out3=in2
>  	tbit.nz p6,p0=in0,CLONE_SETTLS_BIT
> +	cmp.eq p7,p0=in1,r0
>  	mov out4=in3	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
>  	;;
>  (p6)	st8 [r2]=in5				// store TLS in r16 for copy_thread()
> +(p7)	ld8 out1=[r3]	// stack_start: kernel expects a valid value
> +(p7)	mov out3=r0
>  	mov out5=in4	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE_CHILD_CLEARTID
>  	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
>  	mov out0=in0				// out0 = clone_flags
> @@ -146,15 +150,19 @@ GLOBAL_ENTRY(sys_clone)
>  	alloc r16=ar.pfs,8,2,6,0
>  	DO_SAVE_SWITCH_STACK
>  	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
> +	adds r3=PT(AR_BSPSTORE)+IA64_SWITCH_STACK_SIZE+16,sp
>  	mov loc0=rp
>  	mov loc1=r16				// save ar.pfs across do_fork
>  	.body
>  	mov out1=in1
>  	mov out3				// stacksize (compensates for 16-byte scratch area)
>  	tbit.nz p6,p0=in0,CLONE_SETTLS_BIT
> +	cmp.eq p7,p0=in1,r0
>  	mov out4=in2	// parent_tidptr: valid only w/CLONE_PARENT_SETTID
>  	;;
>  (p6)	st8 [r2]=in4				// store TLS in r13 (tp)
> +(p7)	ld8 out1=[r3]	// stack_start: kernel expects a valid value
> +(p7)	mov out3=r0
>  	mov out5=in3	// child_tidptr:  valid only w/CLONE_CHILD_SETTID or CLONE_CHILD_CLEARTID
>  	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
>  	mov out0=in0				// out0 = clone_flags
> Index: ia64_stack_start_V1/arch/ia64/kernel/process.c
> =================================> --- ia64_stack_start_V1.orig/arch/ia64/kernel/process.c	2010-04-25 06:45:22.438977238 -0500
> +++ ia64_stack_start_V1/arch/ia64/kernel/process.c	2010-04-25 06:48:03.671076650 -0500
> @@ -452,7 +452,7 @@ copy_thread(unsigned long clone_flags,
>  	if (likely(user_mode(child_ptregs))) {
>  		if (clone_flags & CLONE_SETTLS)
>  			child_ptregs->r13 = regs->r16;	/* see sys_clone2() in entry.S */
> -		if (user_stack_base) {
> +		if (user_stack_base && user_stack_size) {
>  			child_ptregs->r12 = user_stack_base + user_stack_size - 16;
>  			child_ptregs->ar_bspstore = user_stack_base;
>  			child_ptregs->ar_rnat = 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
