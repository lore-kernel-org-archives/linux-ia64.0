From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 19 Sep 2005 21:32:27 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <ed5aea43050919143261de5085@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/19/05, Christoph Lameter <clameter@engr.sgi.com> wrote:

> Doing two ticks per interrupt may cause hardware to fail that relies on
> the interval accurately being observed. I.e. lets say we have a device
> that typically responds after 10 ticks but times out after 15.
> 
> If we use 2 ticks per interrupt then we will timeout after 15/2 = 7 ticks
> before the device had a chance to do anything.

You're forgetting that the real time has already passed!

> I think all these additional tricks just make the situation worse. My
> patch is already a bad hack and adding more logic just makes follow-on
> failures difficult to analyze. I'd say the cleanest solution is still to
> stick with freezing time. I also do not feel too enthusiastic about
> abusing the time interpolator tuning logic for compenstation.

It was you who suggested to use the time interpolator logic.  My
approach would have been just to keep track of the "deficit" in the
timer interrupt handler.

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
