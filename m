From: Dean Nelson <dcn@sgi.com>
Date: Mon, 23 Aug 2004 16:50:59 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040823165059.GA11321@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 05:39:44PM +0100, Christoph Hellwig wrote:
> On Wed, Jun 16, 2004 at 11:33:39AM -0500, Dean Nelson wrote:
> > --- linux.orig/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:29:44 2004
> > +++ linux/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:31:55 2004
> > @@ -50,6 +50,7 @@
> >  #include <asm/sn/sn2/shub.h>
> >  
> >  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> > +EXPORT_SYMBOL(per_cpu__pda_percpu);
> 
> Umm, no.  Poking into kernel per-cpu data like the pda from modules sounds
> like a bad idea.  And if you absolutely must use the proper helpers for
> exporting it.

Just an FYI, XPC needs to use the enable_shub_wars_1_1() macro which
accesses pda->shub_1_1_found. So we do need to export per_cpu__pda_percpu.
I've switched EXPORT_SYMBOL() to EXPORT_PER_CPU_SYMBOL() instead.

Dean
