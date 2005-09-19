From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 19 Sep 2005 20:16:21 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <ed5aea4305091913161223587d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That depends on the time source and the tuning factor. I guestimate
> it will take about an hour to compensate for 60 seconds. The compensation
> is not linear but should be almost logarithmic since the interpolator will
> detune further if the time difference is greater.

That seems rather slow to me.  Of course, you don't want to catch up
by more than the smallest timeout that you'd like to avoid triggering.
 By that logic, it should be almost guaranteed to be save to account
for 2 ticks per timer interrupt.  That way, it would only take 30 sec
to correct from a 60 sec stand-still.  My gut feeling is that you
could be much more aggressive (e.g., 8 ticks/interrupt) but it might
be a good idea to experiment with this a bit, to get a feel for how
sensitive things really are.  If you wanted to be super-safe, you
could account an extra tick only every other interrupt (i.e., 1.5
ticks/interrupt on average), since timeouts have a rounding-error of
1/2 tick anyhow.

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
