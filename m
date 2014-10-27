From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Date: Mon, 27 Oct 2014 02:17:58 +0000
Subject: RE: [PATCH v9 10/12] x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT, PR_MPX_DISABLE_MANAGEMEN
Message-Id: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED65@shsmsx102.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
 <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.11.1410241436560.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241436560.5308@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>



On 2014-10-24, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>> +int mpx_enable_management(struct task_struct *tsk) {
>> +	struct mm_struct *mm = tsk->mm;
>> +	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
> 
> What's the point of initializing bd_base here. I had to look twice to
> figure out that it gets overwritten by task_get_bounds_dir()
> 

I just want to put task_get_bounds_dir() outside mm->mmap_sem holding.

>> @@ -285,6 +285,7 @@ dotraplinkage void do_bounds(struct pt_regs
>> *regs,
> long error_code)
>>  	struct xsave_struct *xsave_buf;
>>  	struct task_struct *tsk = current;
>>  	siginfo_t info;
>> +	int ret = 0;
>> 
>>  	prev_state = exception_enter();
>>  	if (notify_die(DIE_TRAP, "bounds", regs, error_code, @@ -312,8
>> +313,35 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long
> error_code)
>>  	 */
>>  	switch (status & MPX_BNDSTA_ERROR_CODE) {
>>  	case 2: /* Bound directory has invalid entry. */
>> -		if (do_mpx_bt_fault(xsave_buf))
>> +		down_write(&current->mm->mmap_sem);
> 
> The handling of mm->mmap_sem here is horrible. The only reason why you
> want to hold mmap_sem write locked in the first place is that you want
> to cover the allocation and the mm->bd_addr check.
> 
> I think it's wrong to tie this to mmap_sem in the first place. If MPX
> is enabled then you should have mm->bd_addr and an explicit mutex to protect it.
> 
> So the logic would look like this:
> 
>    mutex_lock(&mm->bd_mutex);
>    if (!kernel_managed(mm))
>       do_trap(); else if (do_mpx_bt_fault()) force_sig();
>    mutex_unlock(&mm->bd_mutex);
> No tricks with mmap_sem, no special return value handling. Straight
> forward code instead of a convoluted and error prone mess.
> 
> Hmm?
> 
I guess this is a good solution. If so, new field 'bd_sem' have to be added into struct mm_struct.

Thanks,
Qiaowei
