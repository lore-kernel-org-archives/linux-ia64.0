From: jbarnes@sgi.com (Jesse Barnes)
Date: Sun, 23 Nov 2003 22:39:29 +0000
Subject: Re: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106962729019919@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106955914311295@msgid-missing>
In-Reply-To: <marc-linux-ia64-106955914311295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Nov 22, 2003 at 09:45:25PM -0600, Jack Steiner wrote:
> I may be overlooking something, but isnt there a problem
> with the udelay() function on IA64 platforms with drifty ITCs
> when preemption is enabled.
> 
> The function uses the ITC for timing. If preemption occurs & the process
> migrates to a different cpu with a much larger ITC value, it
> seems like the delay may be satisfied too quickly.

Yep, it appears so.  I guess we need a 'preempt_disable/disable()' pair
around the itc access.  Of course, callers under a spinlock are already
protected, so maybe exposure to this problem isn't that large?

Jesse
