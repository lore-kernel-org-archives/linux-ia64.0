From: Robin Holt <holt@sgi.com>
Date: Wed, 16 May 2007 22:20:34 +0000
Subject: Re: Re: [PATCH] - Increase max SSI size
Message-Id: <20070516222034.GB14715@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412175819.GA9723@sgi.com>
In-Reply-To: <20070412175819.GA9723@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 16, 2007 at 03:18:27PM -0700, Luck, Tony wrote:
> > Did this make it onto your radar?  Jack had submitted a fixed patch,
> > but I have not seen it sent to Linus yet.  Jack is on vacation right now.
> > If you need it resubmitted, please let me know and I will impersonate him.
> 
> I'd skipped over it.  Just tried it though and something
> is wrong.  I took arch/ia64/gendefconfig and tweaked the
> number of cpus up to 4096.  When I tried to boot it on a
> 16-way Montecito I got an oops during boot.  The full text
> scrolled off the screen, but the last part of the stacktrace
> said:
> 
>  kernel_init -> topology_init -> arch_register_cpu -> register_cpu ->
> 
>     sysdev_register -> kobject_set_name -> kfree

Let me give it a try.

Thanks,
Robin
