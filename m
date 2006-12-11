From: Russ Anderson <rja@sgi.com>
Date: Mon, 11 Dec 2006 19:57:39 +0000
Subject: Re: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
Message-Id: <200612111957.kBBJvdVe59894376@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fenghua Yu wrote:
> On Mon, Dec 11, 2006 at 03:17:26PM +0800, Zhang, Yanmin wrote:
> > On Fri, 2006-12-08 at 16:14 -0800, Fenghua Yu wrote:
> > > +		dbr6		: 1,
> > > +		reserved	: 48;
> > > +} resources_t;
> > Is it better to move above definitions to file include/asm-ia64/pal.h?
> > 
> I'm trying to have the kernel driver as simple as possible and leave
> the complexity to application.

It seems reasonable that structures passed on the PAL_MC_ERROR_INJECT
PAL call be defined in pal.h.

> Currently the driver is dummy; it doesn't know the structure of the paratmers. All it does is to provide a thin interface to call the pal procedure.
> 
> By doing this, I hope we may end up to have a few fancy and complicated applications from the community. In the mean time, we have a small and stable kernel driver underneath.

That would explain the complexity of specifying the bit patterns of 
err_type_info and err_struct_info in err.conf.  Not the friendliest 
user interface.  Sufficient for testing/debugging but a good opportunity
for improvement.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
