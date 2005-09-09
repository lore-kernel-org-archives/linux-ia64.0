From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 09 Sep 2005 23:13:03 +0000
Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by freezing time
Message-Id: <Pine.LNX.4.62.0509091549390.13330@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 9 Sep 2005, David Mosberger-Tang wrote:

> I also would be nervous about the proposed patch.

Yes, I am also a bit concerned but there seems to be no other 
good solution.
 
> I'm wondering: could the problem be avoided perhaps by running all
> other pending (lower-priority) interrupts first when you detect a
> large jump in elapsed time?  In other words, when you detect a jump
> from time T1 to T2 with (T2-T1) greater than some threshold, you make
> sure you run all pending interrupts while still at time T1 and only
> after that is done you let time catch up to T2.

I think we are not talking about hardware interupts. Those can happen 
anytime and given the system was frozen for an extended time period 
likely have already completed before the timer interrupt happens for 
the first time after the system begins to unfreeze.

I think the main issue are drivers events. These are dependent on jiffies 
(which may be checked by drivers in a varity of ways) or are timer events 
(which also may expect jiffies to have a certain value).
