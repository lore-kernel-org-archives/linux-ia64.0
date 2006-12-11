From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 11 Dec 2006 21:08:58 +0000
Subject: Re: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
Message-Id: <20061211210858.GB16623@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 01:57:39PM -0600, Russ Anderson wrote:
> Fenghua Yu wrote:
> > On Mon, Dec 11, 2006 at 03:17:26PM +0800, Zhang, Yanmin wrote:
> > > On Fri, 2006-12-08 at 16:14 -0800, Fenghua Yu wrote:
> > > > +		dbr6		: 1,
> > > > +		reserved	: 48;
> > > > +} resources_t;
> > > Is it better to move above definitions to file include/asm-ia64/pal.h?
> > > 
> > I'm trying to have the kernel driver as simple as possible and leave
> > the complexity to application.
> 
> It seems reasonable that structures passed on the PAL_MC_ERROR_INJECT
> PAL call be defined in pal.h.
> 
> > Currently the driver is dummy; it doesn't know the structure of the paratmers. All it does is to provide a thin interface to call the pal procedure.
> > 
> > By doing this, I hope we may end up to have a few fancy and complicated applications from the community. In the mean time, we have a small and stable kernel driver underneath.
> 
> That would explain the complexity of specifying the bit patterns of 
> err_type_info and err_struct_info in err.conf.  Not the friendliest 
> user interface.  Sufficient for testing/debugging but a good opportunity
> for improvement.

Russ and Yanmin,

The definition of err_type_info and err_struct_info in application does not mean complex user interface. To provide a friendly user interface, another layer can be added on the top of the sample application. For example, a GUI interface which helps user to define various fields like err_type_info etc, then the application verifies the corrections and assembles the fields into pal parameters, finally the application calls the kernel interface to inject error. The purpose of the sample application is to provide a base to add more features like a friendly user interface. 

The field definitions of the parameters in pal.h actually will need the driver to provide more complex user/kernel interfaces. Each field needs a sysfs file to interface with kernel. This will need kernel to provide more than a dozen interface files. And kernel needs to do sanity check for the interface. All of this just addes kernel burden and maintainence. The compleity being moved to application level will provide clean user/kernel interface (only half of dozen sysfs files) and esay to maintain kernel driver (less kernel patches).

Thanks.

-Fenghua


Thanks.

-Fenghua
