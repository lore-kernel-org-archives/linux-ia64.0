From: Alex Chiang <achiang@hp.com>
Date: Wed, 24 Oct 2007 17:26:19 +0000
Subject: Re: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <20071024172619.GA8872@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

* Alex Chiang <achiang@hp.com>:
> * Luck, Tony <tony.luck@intel.com>:
> > > The only real change from the prior version is that I change the
> > > intialization of socket_id to 0 as default. I think the benefit
> > > of displaying information from PAL/SAL (when available) on older
> > > platforms outweighs the oddity that the user may see physical_id
> > > = 0 for multiple CPUs occasionally.
> > 
> > Can't we not print the physical_id if we don't know what it is? That
> > sounds like a better idea than printing wrong information.
> 
> Sure, that sounds like a much better idea. Here's try #3 (go back
> to old initialization of socket_id = -1, and decide in
> show_cpuinfo whether we should print it or not).

Did this patch work for you?

Thanks.

/ac

