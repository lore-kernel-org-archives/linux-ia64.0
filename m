From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 30 Sep 2009 23:06:33 +0000
Subject: Re: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic percpu and drop the old one, take#2
Message-Id: <87hbukxcau.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
	<4AC153EA.2050007@suse.de>
	<57C9024A16AD2D4C97DC78E552063EA3E2F03E58@orsmsx505.amr.corp.intel.com>
	<alpine.DEB.1.10.0909301644460.9271@gentwo.org>
	<57C9024A16AD2D4C97DC78E552063EA3E2F03FDC@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E2F03FDC@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <teheo@suse.de>, Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>>>>> "Tony" = Tony Luck <Luck> writes:

>> Tony: Could we use a global register for the per cpu address? That
>> would make IA64 work similar to sparc.

Tony> Would that be a useful trade of resources for convenience?
Tony> We've already hard-wired r13 for "current". Grabbing another one
Tony> would require fixing (since user code will have clobbered it).
Tony> Possibly re-working any existing code that already uses whatever
Tony> register you choose.

r3, r4 and r5 are currently unused by the kernel, and unused
by GCC and ICC.   Only hand-written assembler and weird compilers use
those registers(and my virtual-machine monitor :-().  If you wanted to
experiment, that'd be a starting place.  

I'm not sure of the advantage though -- TLB mapping is relatively
cheap, and we're no longer hard-wiring the translation register.

You';d have to do somne careful benchmarking on a wide variety of
workloads and machines to get a definitive answer.


---
Dr Peter Chubb        www.nicta.com.au      peter DOT chubb AT nicta.com.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
From Imagination to Impact                       Imagining the (ICT) Future
