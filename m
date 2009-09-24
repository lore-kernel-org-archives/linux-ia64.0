From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 24 Sep 2009 07:36:11 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu
Message-Id: <alpine.DEB.1.10.0909240332130.1488@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org> <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
 <4ABA2A3A.6020308@kernel.org> <alpine.DEB.1.10.0909231315310.4025@V090114053VZO-1> <4ABA9B14.20904@kernel.org>
In-Reply-To: <4ABA9B14.20904@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Thu, 24 Sep 2009, Tejun Heo wrote:

> > How does the new percpu allocator support this? Does it use different
> > methods of access for static and dynamic percpu access?
>
> That's only when __ia64_per_cpu_var() macro is used in arch code which
> always references static perpcu variable in the kernel image which
> falls inside PERCPU_PAGE_SIZE.  For everything else, __my_cpu_offset
> is defined as __ia64_per_cpu_var(local_per_cpu_offset) and regular
> pointer offsetting is used.

So this means that address arithmetic needs to be performed for each
percpu access. The virtual mapping would allow the calculation of the
address at link time. Calculation means that a single atomic instruction
for percpu access wont be possible for ia64.

I can toss my ia64 percpu optimization patches. No point anymore.

Tony: We could then also drop the virtual per cpu mapping. Its only useful
for arch specific code and an alternate method of reference exists.


