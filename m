From: Dean Nelson <dcn@sgi.com>
Date: Wed, 14 Jul 2004 16:01:08 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040714160108.GA10539@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 05:39:44PM +0100, Christoph Hellwig wrote:
> On Wed, Jun 16, 2004 at 11:33:39AM -0500, Dean Nelson wrote:
> >  #include <asm/page.h>
> >  #include <asm/sal.h>
> >  #include <asm/pal.h>
> >  
> >  spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
> > +EXPORT_SYMBOL(sal_lock);
> 
> No.  Please don't make random sal calls from modules.

We're only making one sal call (i.e., SN_SAL_GET_PARTITION_ADDR) to get the
address of a partition's reserved page.

> > +
> >  unsigned long sal_platform_features;
> >  
> >  unsigned short sal_revision;
> > @@ -38,6 +41,8 @@ default_handler (void)
> >  }
> >  
> >  ia64_sal_handler ia64_sal = (ia64_sal_handler) default_handler;
> > +EXPORT_SYMBOL(ia64_sal);
> 
> Dito.  I think you need to find a better abstraction.

What kind of abstraction are you looking for?

In include/asm-ia64/sn/sn_sal.h, there are inline functions that are wrappers
for the SAL_CALL() macro, (for example, ia64_sn_get_console_nasid()). Is this
what you are looking for? (But even if we did create such a function, we'd
still need to export sal_lock and ia64_sal because both are referenced by the
SAL_CALL() macro.) I'd hate to put such an abstraction into sal.c, since the
functionality of my sal call is ia64/sn specific, and sal.c is generic
ia64.

Thanks,
Dean

