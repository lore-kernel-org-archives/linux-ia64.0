From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 16 Nov 2006 16:58:25 +0000
Subject: Re: [PATCH] ia64 add idle loop entry/exit notifier
Message-Id: <20061116165825.GH18162@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061115222334.GE17238@frankl.hpl.hp.com>
In-Reply-To: <20061115222334.GE17238@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

On Wed, Nov 15, 2006 at 06:07:19PM -0800, Chen, Kenneth W wrote:
> Stephane Eranian wrote on Wednesday, November 15, 2006 2:24 PM
> > Here is a patch which adds an idle notifier to IA-64. It clones
> > the one in X86-64. You can register a callback via the notifier
> > and you get called when:
> > 	- entering the lowest level of the idle loop
> > 	- exiting the lowest level of the idle loop, either normally
> > 	  or to process an interrupt
> > 
> > Basically, you can monitor useful vs. useless work accomplished
> > by the idle thread on each processor.
> 
> Is idle notifier a light weight callback thingy?  I happen to work

Well, it uses the notifier interface. I have not changed this part.

> on an application environment that cycles CPUs into gazillion nano
> second sleep due to tons of sleep / wake up activity from thousands
> of processes. I'm just checking and hope this notifier chain isn't
> going to add significant overhead when cycling through busy/idle.
> 
I would suggest you measure the overhead when no callback
is registered. The patch is such that there will systematically be a
callback registered for SGI machines. But if you are cycling busy/idle,
I would think that you biggest cost if coming out of PAL_HALT.

-- 
-Stephane
