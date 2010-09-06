From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 06 Sep 2010 14:47:01 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201009061647.02345.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <201009031652.56476.ptesarik@suse.cz> <AANLkTikZRiQ5jCpgp42LxtXb_S52sSUy7KP_=vZ3z4Tf@mail.gmail.com>
In-Reply-To: <AANLkTikZRiQ5jCpgp42LxtXb_S52sSUy7KP_=vZ3z4Tf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Friday 03 of September 2010 17:50:53 Tony Luck wrote:
> On Fri, Sep 3, 2010 at 7:52 AM, Petr Tesarik <ptesarik@suse.cz> wrote:
> > Anyway, if a global TLB flush is necessary to trigger the bug, it would
> > also explain why we couldn't reproduce it in user-space.
>
> Perhaps ... I did explore the TLB in one variant of my user mode test I
> added a pointer-chasing routine that looked at enough pages to clear out
> the TLB. Not quite the same as a flush - but close.  It didn't help at all.

Hi Tony,

I experimented a lot with the code, trying to find a solution, but all in 
vain. I also tried to add a "dep %0=0,%0,15,2" instruction in the cmpxchg4 
loop in __ticket_spin_lock but it still failed when the wrapped around to 
zero (but now the high word was not even touched).

Replacing the "st2.rel" instruction with a similar cmpxchg4 loop in 
__ticket_spin_unlock did not help either (so we no longer have two accesses 
with different sizes).

What I've seen quite often lately is that the spinlock value is read as "0" by 
the ld4.acq in __ticket_spin_lock(), then as "1" by ld4.acq inside the debug 
fault handler, and then as "0" again by the "cmpxchg4" instruction, i.e. the 
spin lock was actually acquired correctly, but the debug code triggered a 
panic. This made me think that I had an error in my debug code, so I tried 
running that test kernel without the probe, just waiting whether the kernel 
hangs. It did hang within 10 minutes (with 6 parallel test case loops and a 
module load/unload loop on another terminal) and produced a crash dump that 
was very similar all the others.

To sum it up:

1. The ld4.acq and fetchadd.acq instructions fail to give us a coherent view 
of the spinlock memory location.
2. So far, the problem has been observed only after the spinlock value changes 
to zero.
3. It cannot be a random memory scribble, because I employed the DBR registers 
to catch all writes to that memory location.
4. We haven't been able to reproduce the problem in user-space.

Frankly, I think that the processor does not follow the IPF specification, 
hence it is a CPU bug.

But let's be extremely cautious here and re-read the specification once more, 
very carefully. We can still miss some writes to the siglock memory location:

1. if the same physical address is accessible with another virtual address
2. if the siglock location is written by a non-mandatory RSE-spill

Option 2 seems extremely unlikely to me. Option 1 is more plausible, but  
given that I never saw any siglock corruption with a value other than zero, 
it still sounds less likely than a pure CPU bug.

Tony, could you please ask around in Intel if there is any way to debug the 
CPU that would help us spot the real cause?

Petr Tesarik
