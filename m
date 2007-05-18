From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 18 May 2007 00:48:57 +0000
Subject: Re: [PATCH] fix kmalloc(0) in arch/ia64/pci/pci.c
Message-Id: <20070518094857.572e804e.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517110056.779944a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20070517121959.b1b374fa.akpm@linux-foundation.org>
In-Reply-To: <20070517121959.b1b374fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com

On Thu, 17 May 2007 12:19:59 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	if (!windows)
> > +		goto out2;
> >  	controller->window = kmalloc_node(sizeof(*controller->window) * windows,
> >  			GFP_KERNEL, controller->node);
> >  	if (!controller->window)
> > 
> 
> This is a significant change in functionality.  Can you please explain why
> it doesn't break things?
> 
Sorry for long RTT. I found no problem on my machine, but....
I realized I misunderstood how kmalloc(0) works....sorry, please drop patch.

I'll ask a pci guy to fix this.

-Kame

