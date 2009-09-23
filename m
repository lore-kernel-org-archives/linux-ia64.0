From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 02:11:02 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu areas
Message-Id: <4AB983B6.6050203@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1>
In-Reply-To: <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

Christoph Lameter wrote:
> On Tue, 22 Sep 2009, Tejun Heo wrote:
> 
>> +#ifdef	CONFIG_SMP
>> +  . = ALIGN(PERCPU_PAGE_SIZE);
>> +  __cpu0_per_cpu = .;
> 
> __per_cpu_start?
> 
>> +  . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
>> +#endif
> 
> This is a statically sized per cpu area that is used by __get_cpu_var()
> Data is access via a cpu specific memory mapping. How does this work when
> the area grows beyond  PERCPU_PAGE_SIZE? As far as I can see: It seems
> that __get_cpu_var would then cause a memory fault?

On ia64, the first chunk is fixed at PERCPU_PAGE_SIZE.  It's something
hardwired into the page fault logic and the linker script.  Build will
fail if the static + reserved area goes over PERCPU_PAGE_SIZE and in
that case ia64 will need to update the special case page fault logic
and increase PERCPU_PAGE_SIZE.  The area reserved above is interim
per-cpu area for cpu0 which is used between head.S and proper percpu
area setup and will be ditched once initialization is complete.

Thanks.

-- 
tejun
