From: Martin Hicks <mort@wildopensource.com>
Date: Thu, 17 Apr 2003 20:25:21 +0000
Subject: Re: [Linux-ia64] [patch] logical CPU numbering
Message-Id: <marc-linux-ia64-105590723705542@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705277@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705277@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, Apr 17, 2003 at 01:13:44PM -0600, Bjorn Helgaas wrote:
> On Thursday 03 April 2003 11:31 am, Martin Hicks wrote:
> > This patch should be applied.  I finally got around to doing some more
> > testing with it.  If a CPU fails to start, currently we get messages
> > like the following for subsequent CPU's:
> > 
> > 
> > CPU 17: nasid 18, slice 0, cnode 9
> > CPU 17: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz
> > Calibrating delay loop... 1494.72 BogoMIPS
> > phys CPU#17 (0x12) not responding - cannot use it.               <<-BOGUS
> 
> I don't quite understand how this works.  The current code is clearly
> wrong, but if the AP in a 2-CPU system fails to start, won't the new
> code print "phys CPU#0 not responding"?  That doesn't seem accurate.
> 
> If we really need this printk, it seems like the logical place to put it
> would be in do_boot_cpu(), where we already print the "Processor X/Y
> is stuck" message.  2.5 seems to have just removed the "not responding"
> printk, though, and I'd be inclined to do the same.  Any objections?

I have no objections.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com

