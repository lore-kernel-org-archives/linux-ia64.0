From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 28 Sep 2009 15:12:10 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu
Message-Id: <alpine.DEB.1.10.0909281104060.12252@gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org> <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
 <4ABA2A3A.6020308@kernel.org> <alpine.DEB.1.10.0909231315310.4025@V090114053VZO-1> <4ABA9B14.20904@kernel.org> <alpine.DEB.1.10.0909240332130.1488@V090114053VZO-1> <4ABB2FE3.40608@kernel.org>
In-Reply-To: <4ABB2FE3.40608@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Thu, 24 Sep 2009, Tejun Heo wrote:

> percpu implementation on ia64 has always been like that.  The problem
> with the alternate mapping is that you can't take the pointer to it as
> it would mean different thing depending on which processor you're on
> and the overall generic percpu implementation expects unique addresses
> from percpu access macros.

The cpu ops patchset uses per cpu addresses that are not relocated to a
certain processor. The relocation is implicit in these instructions and
must be implicit so these operations can be processor atomic.

> ia64 currently has been and is the only arch which uses virtual percpu
> mapping.  The one biggest benefit would be accesses to the
> local_per_cpu_offset.  Whether it's beneficial enough to justify the
> complexity, I frankly don't know.

Its not worth working on given the state of IA64. I talked to Tony at the
Plumbers conference. It may be beneficial to drop the virtual percpu
mapping entirely because that would increase the number of TLB entries
available.

> Andrew once also suggested taking advantage of those overlapping
> virtual mappings for local percpu accesses.  If the generic code
> followed such design, ia64's virtual mappings would definitely be more
> useful, but that means we would need aliased mappings for percpu areas
> and addresses will be different for local and remote accesses.  Also,
> getting it right on machines with virtually mapped caches would be
> very painful.  Given that %gs/fs offesetting is quite efficient on
> x86, I don't think changing the generic mechanism is worthwhile.

There is no problem with using unrelocated percpu addresses as an
"address" for the cpu ops. The IA64 "virtual" addresses are a stand in for
the segment registers on IA64.

> So, it would be great if we can find a better way to offset addresses
> on ia64.  If not, nothing improves or deteriorates performance-wise
> with the new implementation.

Dropping the use of the special mapping over time may be the easiest way
to go for IA64. percpu RMW ops like this_cpu_add are not possible with
IA64 since no lightweight primitives exist. We could only avoid the
calculation of the per cpu variables address. Would allow assignment and
access to be atomic but not the RMW instruction. So it would not be a full
per cpu ops implementation anyways.

