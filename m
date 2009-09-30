From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 30 Sep 2009 23:49:50 +0000
Subject: Re: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic percpu
Message-Id: <alpine.DEB.1.10.0909301946510.11850@gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org> <4AC153EA.2050007@suse.de> <57C9024A16AD2D4C97DC78E552063EA3E2F03E58@orsmsx505.amr.corp.intel.com> <alpine.DEB.1.10.0909301644460.9271@gentwo.org> <57C9024A16AD2D4C97DC78E552063EA3E2F03FDC@orsmsx505.amr.corp.intel.com>
 <87hbukxcau.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87hbukxcau.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: "Luck, Tony" <tony.luck@intel.com>, Tejun Heo <teheo@suse.de>, Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 1 Oct 2009, Peter Chubb wrote:

> r3, r4 and r5 are currently unused by the kernel, and unused
> by GCC and ICC.   Only hand-written assembler and weird compilers use
> those registers(and my virtual-machine monitor :-().  If you wanted to
> experiment, that'd be a starting place.
>
> I'm not sure of the advantage though -- TLB mapping is relatively
> cheap, and we're no longer hard-wiring the translation register.

Dynamic and static per cpu variables could use relative access to that
register. This would reduce code size, avoid the use of a TLB entry.

> You';d have to do somne careful benchmarking on a wide variety of
> workloads and machines to get a definitive answer.

I have some patches here that make heavy use of dynamic percpu allocations
in the allocators to optimize the alloc / free paths.

