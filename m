From: Tejun Heo <tj@kernel.org>
Date: Thu, 24 Sep 2009 08:37:55 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu areas
Message-Id: <4ABB2FE3.40608@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org> <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1> <4ABA2A3A.6020308@kernel.org> <alpine.DEB.1.10.0909231315310.4025@V090114053VZO-1> <4ABA9B14.20904@kernel.org> <alpine.DEB.1.10.0909240332130.1488@V090114053VZO-1>
In-Reply-To: <alpine.DEB.1.10.0909240332130.1488@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

Hello, Christoph.

Christoph Lameter wrote:
> On Thu, 24 Sep 2009, Tejun Heo wrote:
> 
>>> How does the new percpu allocator support this? Does it use different
>>> methods of access for static and dynamic percpu access?
>> That's only when __ia64_per_cpu_var() macro is used in arch code which
>> always references static perpcu variable in the kernel image which
>> falls inside PERCPU_PAGE_SIZE.  For everything else, __my_cpu_offset
>> is defined as __ia64_per_cpu_var(local_per_cpu_offset) and regular
>> pointer offsetting is used.
> 
> So this means that address arithmetic needs to be performed for each
> percpu access. The virtual mapping would allow the calculation of the
> address at link time. Calculation means that a single atomic instruction
> for percpu access wont be possible for ia64.
> 
> I can toss my ia64 percpu optimization patches. No point anymore.
> 
> Tony: We could then also drop the virtual per cpu mapping. Its only useful
> for arch specific code and an alternate method of reference exists.

percpu implementation on ia64 has always been like that.  The problem
with the alternate mapping is that you can't take the pointer to it as
it would mean different thing depending on which processor you're on
and the overall generic percpu implementation expects unique addresses
from percpu access macros.

ia64 currently has been and is the only arch which uses virtual percpu
mapping.  The one biggest benefit would be accesses to the
local_per_cpu_offset.  Whether it's beneficial enough to justify the
complexity, I frankly don't know.

Andrew once also suggested taking advantage of those overlapping
virtual mappings for local percpu accesses.  If the generic code
followed such design, ia64's virtual mappings would definitely be more
useful, but that means we would need aliased mappings for percpu areas
and addresses will be different for local and remote accesses.  Also,
getting it right on machines with virtually mapped caches would be
very painful.  Given that %gs/fs offesetting is quite efficient on
x86, I don't think changing the generic mechanism is worthwhile.

So, it would be great if we can find a better way to offset addresses
on ia64.  If not, nothing improves or deteriorates performance-wise
with the new implementation.

Thanks.

-- 
tejun
