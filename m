From: Christoph Lameter <christoph@lameter.com>
Date: Tue, 08 Jun 2004 21:48:20 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406081439440.17461@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 8 Jun 2004, David Mosberger wrote:

> >>>>> On Tue, 8 Jun 2004 11:32:46 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:
>
>   Christoph> This does not effect the update of last_itc which does
>   Christoph> not depend on any of the variables you mention. The
>   Christoph> dependency existed for last_nsec_offset but does NOT
>   Christoph> exist for last_itc. There is much more than just a name
>   Christoph> change going on.
>
> Let me try this again: the second you update a global variable with a
> bogus/inconsistent value, another CPU may observe that value.  The
> fact that you're going to try to correct that bad value later on
> doesn't help you at all.  See the problem now?

Please show me how last_itc can *receive* a bogus value. What you are
saying cannot happen because last_itc does not depend in any way on
variables modified by the timer interrupt. Last_itc is updated using a
cmpxchg which will deal with the problem of multiple CPUs updating the
value.

A bogus value may be returned from get_offset if a timer interrupt
happens and is then properly disposed of later.

> The fundamental issue is that with ITC-based interpolation, reading
> the offset has a side-effect, which isn't true for global-timer-based
> interpolation.  Hence the need for a two-phase protocol.

It does not need to have the side effect (like the use of
last_nsec_offset) if the ITC is monotonized and
therefore works like a global timer.

Here is the offset routine after my modifications. last_itc is in no way
depending on any of the timer variables but only on ITC. The timer
interrupt cannot cause an bogus value to be written to last_itc:

unsigned long
itc_get_offset (void)
{
        static unsigned long last_itc=0;
        unsigned long elapsed_cycles, lost;
        unsigned long now, last_tick;
        unsigned long litc;

        /* Determine ITC value that is >= than the last one used */
        do {
                litc=last_itc;
                now = ia64_get_itc();
                lost = jiffies - wall_jiffies;
                last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
                     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);

                /* Make sure time does not run backwards but allow warparound */
                if (last_itc && now<last_itc && last_itc-now<0x8000000000000000UL)
                {
                        /* Time would be running backwards if we would use this ITC value.
                         * Use the last ITC value instead.
                         */
                        now=litc;
                        break;
                }
        } while (unlikely(cmpxchg(&last_itc,litc,now)));

        elapsed_cycles = now - last_tick;
        return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT;
}
