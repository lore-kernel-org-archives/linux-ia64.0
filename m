From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 29 Jul 2004 18:48:04 +0000
Subject: Re: Timer updates revision 6 (+jitter control/tuning/unification to
Message-Id: <Pine.LNX.4.58.0407291142580.912@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 29 Jul 2004, David Mosberger wrote:

> Hmmh, something is really strange about that machine.  I have never
> seen anything close to 200 cycles, even on McKinley (which does need
> the Errata 9 workaround, which costs about 10 cycles for an
> fsys-call).  I'm seeing 153 cycles for your code on a 1GHz McKinley
> with your latest code (and 136 cycles on a 900MHz McKinley with a
> plain 2.6.7 kernel).

There are other machines around but this one has 4 processors which is
good for scalability testing. Numbers are much better cycles on another
1.5 Ghz 2 CPU box.

>   Christoph> Putting 6 cmps/tbits in one cycle would do it yes. But I
>   Christoph> still would like to have a bitmap to set options on how
>   Christoph> to handle the counters.
>
> But some of the choices are mutually exlusive.  It doesn't make sense
> to have ITC-based interpolation AND external-timer-based interpolation
> enabled at the same time.  In fact, your code would break if that were
> the case.  For mutually exlusive choices, it would be much better to
> use an enumeration type, as you did in the earlier version of your
> patch.

Ok. Will do but this may waste some cycles on extracting the parameters.

>   Christoph> However the two above code samples have the same effect
>   Christoph> if I understand correctly what you wanted to say. The cmp
>   Christoph> is doing a signed subtract for testing.
>
> No, they're not equivalent.  Suppose:
>
>    last_cycle = 0x7fffffffffffffff (+9223372036854775807)
>    cycle      = 0x8000000000000000 (-9223372036854775808)
>
> then you'd get:
>
>    (last_cycle <s64= cycle) = FALSE ("<s64=" being signed 64-bit comparison),
>
> since
>
>    9223372036854775807 > -9223372036854775808
>
> whereas:
>
>   (cycle - last_cycle) = 1 > 0
>

Ahh.... Thanks.

