From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Mar 2008 14:55:52 +0000
Subject: Re: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <alpine.LFD.1.00.0803210744470.3020@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain> <20080319212024.EA03126F995@magilla.localdomain> <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org> <20080320081658.0B23826F995@magilla.localdomain>
In-Reply-To: <20080320081658.0B23826F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org



On Thu, 20 Mar 2008, Roland McGrath wrote:
> 
> The motivation is to get the arch function out of the code path for the
> machine-independent request handling.  I want to be able to change the
> implementation later without touching the arch code again.  

If there is no stronger motivation than that, then I don't want to have 
this ugly and unnecessary complication.

I really don't see the advantage of doing

	/* We can't handle it, let the generic code sort it out */
	return -ENOSYS;

over a

	/* We can't handle it, let the generic code sort it out */
	return ptrace_request(child, request, addr, data);

in the arch-specific code, and I think the latter version is *much* 
preferable if it avoids this whole unnecessary new abstraction crud and 
odd testing in the generic part.

> The reason I took the approach I did instead is incrementalism.
> I can't change that signature without breaking about 22 arch builds.

Don't worry about the arch builds. If that's your main worry and reason 
for this, it's not worth it. Yes, ptrace changes, and yes, we may have 
arch issues, but no, it's not that big of a deal. Just break them.

Make sure x86[-64] works, and make sure that other architectures *can* 
work (and explain it on linux-arch) when you have to fix something up, but 
ptrace is a blip on the radar for people, it's not going to be a huge 
issue.

> I'm only really prepared to thoroughly verify a change on 2 of those
> myself.

.. and you really aren't expected to. It's why we have architecture 
people: if there is a good reason for the change (ie it's not just some 
churn for churns sake), it's largely up to them to make sure the code 
works.

Sure, you need to be able to explain the interface changes and answer 
questions, but as mentioned, the ptrace code is not a big deal: it has 
lots of tiny _details_, but it's not conceptually complex code.

> So this ugliness seemed like a better bet than waiting for 20 more
> arch sign-offs before any of it could go in.

Really, that has never been a major concern. I will _happily_ break the 
odd architectures if I see that it's a matter of changing over some 
detail (ie it's not some fundamentally hard issue for an arch maintaner to 
fix up).

I think it's *wrong* to add a new an odd calling convention that is less 
readable than what we have now, just to try to avoid something like this 
that really isn't a big problem. It's not like we haven't broken 
architectures over ptrace in the past, and it's also not like it's an area 
that I think anybody has ever lost sleep over..

			Linus
