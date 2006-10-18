From: Jack Steiner <steiner@sgi.com>
Date: Wed, 18 Oct 2006 21:55:30 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061018215530.GB31516@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 18, 2006 at 02:44:13PM -0700, Stephane Eranian wrote:
> Jack,
> 
> The perfmon subsystem will not work correctly if you mix
> Madison and Montecito in the same box. And there is not an
> easy way to make it work with such configuration. Performance
> counters are different between the two models.
 
The failing case that I ran into was a mixture of rev 5 & rev 7
montecitos:
        Intel(r) Itanium(r) 2 Processor 1.6GHz with 24M L3 Cache for 533MHz Platforms
        Intel(r) Itanium(r) 2 Processor 1.6GHz with 18M L3 Cache for 533MHz Platforms

I assume that will work ok. Right?

However, there is also a patch that Russ Anderson pushed last week (at least
I think he pushed it). We are planning to support systems with mixtures of both
madison & montecito. Sounds like we have a problem :-(

I'll cc Russ.

Thanks

> The only thing we could do, is to detect such condition
> and default to the architectured PMU.
> 
> 
> On Wed, Oct 18, 2006 at 04:25:59PM -0500, Jack Steiner wrote:
> > 
> > If a system consists of mixed processor types, kmalloc()
> > can be called before the per-cpu data page is initialized. 
> > If the slab contains sufficient memory, then kmalloc() works
> > ok. However, if the slabs are empty, slab calls the memory
> > allocator. This requires per-cpu data (NODE_DATA()) & the
> > cpu dies.
> > 
> > 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> > 
> > 
> > 
> > 
> > Index: linux/arch/ia64/kernel/setup.c
> > =================================> > --- linux.orig/arch/ia64/kernel/setup.c	2006-10-18 15:49:49.000000000 -0500
> > +++ linux/arch/ia64/kernel/setup.c	2006-10-18 16:19:18.261790796 -0500
> > @@ -643,12 +643,14 @@ struct seq_operations cpuinfo_op = {
> >  	.show =		show_cpuinfo
> >  };
> >  
> > -static char brandname[128];
> > +#define MAX_BRANDS	4
> > +static char brandname[MAX_BRANDS][128];
> >  
> >  static char * __cpuinit
> >  get_model_name(__u8 family, __u8 model)
> >  {
> >  	char brand[128];
> > +	int i;
> >  
> >  	if (ia64_pal_get_brand_info(brand)) {
> >  		if (family = 0x7)
> > @@ -660,12 +662,14 @@ get_model_name(__u8 family, __u8 model)
> >  		} else
> >  			memcpy(brand, "Unknown", 8);
> >  	}
> > -	if (brandname[0] = '\0')
> > -		return strcpy(brandname, brand);
> > -	else if (strcmp(brandname, brand) = 0)
> > -		return brandname;
> > -	else
> > -		return kstrdup(brand, GFP_KERNEL);
> > +	for (i = 0; i < MAX_BRANDS; i++)
> > +		if (strcmp(brandname[i], brand) = 0)
> > +			return brandname[i];
> > +	for (i = 0; i < MAX_BRANDS; i++)
> > +		if (brandname[i][0] = '\0')
> > +			return strcpy(brandname[i], brand);
> > +	BUG();
> > +	return NULL;	/* quiet compiler */
> >  }
> >  
> >  static void __cpuinit
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> 
> -Stephane

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


