From: Andrew Lutomirski <luto@mit.edu>
Date: Tue, 07 Jun 2011 20:35:52 +0000
Subject: Re: [PATCH 4/5] clocksource: Replace vread and fsys_mmio with generic
Message-Id: <BANLkTimU75BNGxTSDicAf5uJdaxqDUu57Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1307474707.git.luto@mit.edu> <4a233d5b7421ef8f7805139e3eba68c52c2d0d57.1307474707.git.luto@mit.edu>
 <1307478514.3163.49.camel@work-vm>
In-Reply-To: <1307478514.3163.49.camel@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Clemens Ladisch <clemens@ladisch.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 7, 2011 at 4:28 PM, john stultz <johnstul@us.ibm.com> wrote:
> On Tue, 2011-06-07 at 15:32 -0400, Andy Lutomirski wrote:
>> The vread field was bloating struct clocksource everywhere except
>> x86_64, and I want to change the way this works on x86_64, so let's
>> split it out into per-arch data.
> [snip]
>> diff --git a/arch/ia64/include/asm/clocksource.h b/arch/ia64/include/asm/clocksource.h
>> new file mode 100644
>> index 0000000..453f363
>> --- /dev/null
>> +++ b/arch/ia64/include/asm/clocksource.h
>> @@ -0,0 +1,16 @@
>> +/* x86-specific clocksource additions */
>> +
>> +#ifndef _ASM_X86_CLOCKSOURCE_H
>> +#define _ASM_X86_CLOCKSOURCE_H
>> +
>> +#ifdef CONFIG_X86_64
>
> Why do we want X86_64 ifdefs in the ia64 clocksource.h?
>

We don't.  That was a copy-and-paste-o.

>
> Overall this sort of feels a little messy to me.
>
> While having the ifdefs in the clocksource structure wasn't great, I'm
> not super excited about pushing all of this back into arch-specific
> code. The hope was that folks like ppc and ia64 would convert over from
> their own implementations to using more generic vread() implementations,
> or atleast new arches with vdso implementations would make use of it
> (possibly even allowing for a generic vdso gettime implementation).
>
> Are there at least some hard numbers that help justify this? Or maybe
> could you provide some thoughts on your future plans?

No numbers because there's no speedup (yet).  Although I do want to
inline at least the TSC implementation eventually.

The real reason is security.  Having vread be a function pointer
implies that userspace code can find that function at a fixed address,
which is a bad idea from a security POV (and I hope it's not even true
on any architecture except x86-64).  The x86-64 vsyscall is finally
cleaned up to the point that the vread functions are the only pieces
user-executable code left at a fixed address, and I want to get rid of
them as well.

The followup change (patch 5) changes vread on x86-64 to specify TSC,
HPET, or fallback to syscall, and the vDSO reads it and acts
accordingly.  This is unfortunate in that it hardcodes assumptions
about the clocksources.

The only other way I can think of to do it is to make the pointer
point into the vDSO.  That would involve making it relative to
something in the vDSO, which would IMO be messier both in terms of
computing the pointer and in terms of calling whatever it points to.


Note that the vsyscall_fn hack is rather x86-64-specific as is.


--Andy
