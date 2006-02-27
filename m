From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Mon, 27 Feb 2006 22:15:37 +0000
Subject: Re: [patch] Increase severity of MCA recovery messages
Message-Id: <200602272215.k1RMFbHJ1470534@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602272012.k1RKCHwW1469428@efs.americas.sgi.com>
In-Reply-To: <200602272012.k1RKCHwW1469428@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
>
> > The MCA recovery messages are currently KERN_DEBUG,
> > so they don't show up in /var/log/messages (by default).
> > Increase the severity to KERN_CRIT, which is the
> > severity used when the kernel kills out of memory
> > processes.
> 
> -	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
> +	printk(KERN_CRIT "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
> 
> This one definitely needs a much bigger severity than DEBUG ... but is
> it really as high as CRIT?  The whole point of the error recovery code
> is that we (the system) do in fact recover (though at the expense of
> killing a process).  Perhaps KERN_ERR?  But I'd like to hear opinions
> on this.

In side discussions, the argument for KERN_CRIT was that a process is
killed.

The argument for KERN_ERR is that it is a hardware error, even though
the system did not crash.

The argument for KERN_WARN is that recovery is "normal".

A closer look at __oom_kill_task() shows it uses KERN_ERR when killing
a process.

> -		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
> +		printk(KERN_CRIT "Page isolation: ( %lx ) success.\n", paddr);
> 
> -		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
> +		printk(KERN_CRIT "Page isolation: ( %lx ) failure.\n", paddr);
> 
> But these ones ... I'm not so sure about.  We have already printed the first
> message ... and don't take any different action whether we succeed or fail
> at isolating the page.  Perhaps failure to isolate is a big problem, but
> succesfully isolating isn't?  Though getting the physical address logged
> would seem to be pretty useful (maybe it should be in the first printk?)

The success message is clearly lower priority than the failure.
The failure message is a big problem because you will go down,
though the failure to recover is not the root cause.

My opinion is the first should be at least KERN_ERR, following
the example of __oom_kill_task().  The success message should 
be KERN_WARN and the failure message KERN_CRIT because the 
system will be going down.  



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
