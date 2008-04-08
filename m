From: Russ Anderson <rja@sgi.com>
Date: Tue, 08 Apr 2008 18:21:46 +0000
Subject: Re: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <20080408182146.GB8872@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 08, 2008 at 10:51:42AM -0700, Luck, Tony wrote:
> > I think kdump_on_fatal_mca should be set to 1 by default. Fatal
> > mca is exactly the case where we need a dump to analyze the problem.
> 
> I'm not so sure.  If the fatal MCA was caused by the s/w doing something
> wrong (e.g. accessing non-existant memory), then a dump is useful to find out
> what went wrong.
> 
> But if the MCA was caused by some h/w error (e.g. 2xECC bit error in kernel
> memory), then a dump won't help.
> 
> Perhaps the dump would help distinguish the s/w case from the h/w case?

Yes.  We generally try to take a dump after a crash to collect all
the available data.  The analysis of the data (to determine h/w or
s/w) occurs after the reboot.

As an alternative, could kdump_on_fatal_mca be turned on by 
default in Altix (in the Altix specific boot code)?  Then
we could set our default without impacting other vendors.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
