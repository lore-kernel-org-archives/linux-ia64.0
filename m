From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 03 Sep 2010 09:04:37 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201009031104.38433.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <20100902002641.GI18967@zorg.emea.sgi.com> <AANLkTimCOWvBs1pdWeMZD9DR=u2ioFPXt7Jja73VQaZn@mail.gmail.com>
In-Reply-To: <AANLkTimCOWvBs1pdWeMZD9DR=u2ioFPXt7Jja73VQaZn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Friday 03 of September 2010 02:06:33 Tony Luck wrote:
> Today's experiments were inspired by Petr's comment at the start of this
> thread:
>
>    "Interestingly, CPU 5 and CPU 7 are both granted the same ticket"
>
> I added an "owner" element to every lock - I have 32 cpus, so I made
> it "unsigned int". Then added to the lock and trylock paths code to
> check that owner was 0 when the lock was granted, followed by:
> lock->owner |= (1u << cpu);  Then in the unlock path I check that just
> the (1u << cpu) bit is set before doing: lock->owner &= ~(1u << cpu);
>
> In my first test I got a hit. cpu28 had failed to get the lock and was
> spinning holding ticket "1". When "now serving" hit 1, cpu28 saw that
> the owner field was set to 0x1, indicating that cpu0 had also claimed
> the lock. The lockword was 0x20002 at this point ... so cpu28 was
> correct to believe that the lock had been freed and handed to it.  It
> was unclear why cpu0 had muscled in and set its bit in the owner
> field. Also can't tell whether that was a newly allocated lock, or one
> that had recently wrapped around.
>
> Subsequent tests have failed to reproduce that result - system just
> hangs without complaining about multiple cpus owning the same lock at
> the same time - perhaps because of the extra tracing I included to
> capture more details.

I did some extensive testing of the issue. I wrote a Kprobe that attaches to 
copy_process and if the new task is one of the "count" processes, it sets up 
a pair of DBR registers to watch for all writes to the siglock. (Obviously, I 
had to limit parallel runs of "count" to 4, because there are only 8 dbr 
registers.) When I hit the breakpoint, I record the old value (with ld4.acq), 
single step one instruction and read the new value (with ld4.acq). The code 
panics the machine (producing a core-dump) if neither the new head is larger 
than the old head nor the new tail is larger than the old tail.

What I got is rather disturbing. I got three different traces so far, all of 
them on the same fetchadd4.acq instruction. The observed values are:

   BEFORE   reg   AFTER   DUMP
A.    0      1       0      0
B.    1      0       1      1
C.    0      1       0      1

BEFORE .. value seen by ld4.acq in the first debug fault
reg .. value in the target register of fetchadd
AFTER .. value seen by ld4.acq after single step
DUMP .. value saved to the crash dump

Interestingly, sometimes there was no write recorded with the new value equal 
to the BEFORE column. Then it occured to me that I probably missed some 
writes from interrupt context, because psr.db gets cleared by the CPU. So I 
modified ivt.S so that it explicitly re-enabled psr.db. And I got a crash 
dump with variant C.

I thought that I still missed some writes somehow, but consider that I never 
got any failures other than after a wrap-around, even though the code would 
catch any case where the lock does not increment correctly.

Moreover, variant B cannot be explained even if I did miss a fetchadd4. How 
can we get 1 on the first ld4.acq, and then 0 from the fetchadd4.acq?

I'm now trying to modify the lock primitives:

1. replace the fetchadd4.acq with looping over cmpxchg
2. replace the st2.rel with looping over cmpxchg

I'll write again when I have the results.

Petr Tesarik
