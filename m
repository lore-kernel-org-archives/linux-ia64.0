From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 24 Oct 2014 15:10:35 +0000
Subject: Re: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT, PR_MPX_DISABLE_MANAGEMEN
Message-Id: <alpine.DEB.2.11.1410241710020.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241436560.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241436560.5308@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Fri, 24 Oct 2014, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> > +int mpx_enable_management(struct task_struct *tsk)
> > +{
> > +	struct mm_struct *mm = tsk->mm;
> > +	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
> 
> What's the point of initializing bd_base here. I had to look twice to
> figure out that it gets overwritten by task_get_bounds_dir()
> 
> > @@ -285,6 +285,7 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
> >  	struct xsave_struct *xsave_buf;
> >  	struct task_struct *tsk = current;
> >  	siginfo_t info;
> > +	int ret = 0;
> >  
> >  	prev_state = exception_enter();
> >  	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
> > @@ -312,8 +313,35 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
> >  	 */
> >  	switch (status & MPX_BNDSTA_ERROR_CODE) {
> >  	case 2: /* Bound directory has invalid entry. */
> > -		if (do_mpx_bt_fault(xsave_buf))
> > +		down_write(&current->mm->mmap_sem);
> 
> The handling of mm->mmap_sem here is horrible. The only reason why you
> want to hold mmap_sem write locked in the first place is that you want
> to cover the allocation and the mm->bd_addr check.
> 
> I think it's wrong to tie this to mmap_sem in the first place. If MPX
> is enabled then you should have mm->bd_addr and an explicit mutex to
> protect it.
> 
> So the logic would look like this:
> 
>    mutex_lock(&mm->bd_mutex);
>    if (!kernel_managed(mm))
>       do_trap();
>    else if (do_mpx_bt_fault())
>       force_sig();
>    mutex_unlock(&mm->bd_mutex);
>    
> No tricks with mmap_sem, no special return value handling. Straight
> forward code instead of a convoluted and error prone mess.

After thinking about the deallocation issue, this would be mm->bd_sem.

Thanks,

	tglx
