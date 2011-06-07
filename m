From: john stultz <johnstul@us.ibm.com>
Date: Tue, 07 Jun 2011 21:06:20 +0000
Subject: Re: [PATCH 4/5] clocksource: Replace vread and fsys_mmio with
Message-Id: <1307480780.3163.68.camel@work-vm>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1307474707.git.luto@mit.edu>
	 <4a233d5b7421ef8f7805139e3eba68c52c2d0d57.1307474707.git.luto@mit.edu>
	 <1307478514.3163.49.camel@work-vm>
	 <BANLkTimU75BNGxTSDicAf5uJdaxqDUu57Q@mail.gmail.com>
In-Reply-To: <BANLkTimU75BNGxTSDicAf5uJdaxqDUu57Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Lutomirski <luto@mit.edu>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Clemens Ladisch <clemens@ladisch.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, 2011-06-07 at 16:35 -0400, Andrew Lutomirski wrote:
> On Tue, Jun 7, 2011 at 4:28 PM, john stultz <johnstul@us.ibm.com> wrote:
> >
> > While having the ifdefs in the clocksource structure wasn't great, I'm
> > not super excited about pushing all of this back into arch-specific
> > code. The hope was that folks like ppc and ia64 would convert over from
> > their own implementations to using more generic vread() implementations,
> > or atleast new arches with vdso implementations would make use of it
> > (possibly even allowing for a generic vdso gettime implementation).
> >
> > Are there at least some hard numbers that help justify this? Or maybe
> > could you provide some thoughts on your future plans?
> 
> No numbers because there's no speedup (yet).  Although I do want to
> inline at least the TSC implementation eventually.
> 
> The real reason is security.  Having vread be a function pointer
> implies that userspace code can find that function at a fixed address,
> which is a bad idea from a security POV (and I hope it's not even true
> on any architecture except x86-64).

Something to this effect should go into the change-log then.

>   The x86-64 vsyscall is finally
> cleaned up to the point that the vread functions are the only pieces
> user-executable code left at a fixed address, and I want to get rid of
> them as well.
> 
> The followup change (patch 5) changes vread on x86-64 to specify TSC,

Oh, sorry, I didn't see the rest of the patchset. Apologies. :)


> HPET, or fallback to syscall, and the vDSO reads it and acts
> accordingly.  This is unfortunate in that it hardcodes assumptions
> about the clocksources.

Yea, that is unfortunate. Hmm.

> The only other way I can think of to do it is to make the pointer
> point into the vDSO.  That would involve making it relative to
> something in the vDSO, which would IMO be messier both in terms of
> computing the pointer and in terms of calling whatever it points to.

Hrm. I'm not super familiar with how the vDSO randomization works, so I
can't really provide any informed insight here.

But I'd def like to someday get the vDSO stuff to be as generic as
possible. I already have some timekeeping changes I'd like to do which
affect the update_vsyscall path. And that is a total pain to do, since I
have to sync changes with x86, powerpc and ia64 (and the ia64 asm isn't
something I'm likely to touch :) and get those changes in all at once,
or introduce some redundant call or have lots of ifdef magic to keep
compatibility while each arch adapts to the changes.

So yea, I guess the fixed pointer removal is a priority, but I suspect
these changes will cause some maintenance pain in the future.

thanks
-john


