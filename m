From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Jul 2004 18:32:37 +0000
Subject: Re: Timer updates revision 6 (+jitter control/tuning/unification to
Message-Id: <16649.17093.467094.726100@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Jul 2004 07:29:16 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> The system is an Intel SDV (4 CPUs at 900 Mhz) and AFAIK
  Christoph> it has McKinley CPUs. Says the following on bootup:

  Christoph> Leaving McKinley Errata 9 workaround enabled.

Hmmh, something is really strange about that machine.  I have never
seen anything close to 200 cycles, even on McKinley (which does need
the Errata 9 workaround, which costs about 10 cycles for an
fsys-call).  I'm seeing 153 cycles for your code on a 1GHz McKinley
with your latest code (and 136 cycles on a 900MHz McKinley with a
plain 2.6.7 kernel).

  Christoph> Putting 6 cmps/tbits in one cycle would do it yes. But I
  Christoph> still would like to have a bitmap to set options on how
  Christoph> to handle the counters.

But some of the choices are mutually exlusive.  It doesn't make sense
to have ITC-based interpolation AND external-timer-based interpolation
enabled at the same time.  In fact, your code would break if that were
the case.  For mutually exlusive choices, it would be much better to
use an enumeration type, as you did in the earlier version of your
patch.

  >> ld8 r26 = [r22]		// time_interpolator->last_counter

  Christoph> This is meant to be

  Christoph> (p13) ld8 r25 = [r23]         // time interpolator->last_cycle

  Christoph> right?

Yes, I made a cut & paste error.

  >> (p13)	cmp.gt.unc p6,p7 = r25,r2	// check if it is less than last. p6,p7 cleared

  >> shouldn't it do something along the lines of:

  >> (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
  >> (p13)	ld8 r25 = [r23]		// time interpolator->last_cycle
  >> (p13)	sub rTMP = r25,r2
  >> (p13)	cmp.gt.unc p6,p7 = rTMP,r0 // check if it is less than last. p6,p7 cleared

  >> so ITC-wrap-around is handled correctly?

  Christoph> The current dejitter code has a problem for other reasons
  Christoph> because it sets r2 after r2 has already been used to
  Christoph> calculate the time difference.

OK.

  Christoph> However the two above code samples have the same effect
  Christoph> if I understand correctly what you wanted to say. The cmp
  Christoph> is doing a signed subtract for testing.

No, they're not equivalent.  Suppose:

   last_cycle = 0x7fffffffffffffff (+9223372036854775807)
   cycle      = 0x8000000000000000 (-9223372036854775808)

then you'd get:

   (last_cycle <s64= cycle) = FALSE ("<s64=" being signed 64-bit comparison),

since

   9223372036854775807 > -9223372036854775808

whereas:

  (cycle - last_cycle) = 1 > 0

  >> This one:

  >> cmp.lt p6, p0 = CLOCK_MONOTONIC, r32

  >> should be cmp4.lt, since clockid_t appears to be an "int" on ia64, no?

  Christoph> I thought arguments are sign extended so either would
  Christoph> work.

The ia64 ABI makes no such guarantee.  The top 32 bits may contain
garbage (though GCC doesn't normally generate such code).

  Christoph> If that is not the case though then we might have found
  Christoph> the reason that the function falls back to the C code on
  Christoph> your box.

Actually, I did change it to cmp4 already but it doesn't matter in
this particular case because the GCC-generated libc code does indeed
(needlessly) sign-extend the value.

	--david
