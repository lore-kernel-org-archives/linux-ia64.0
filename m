From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 11 Dec 2006 18:12:24 +0000
Subject: Re: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
Message-Id: <20061211181224.GB9731@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 03:17:26PM +0800, Zhang, Yanmin wrote:
> On Fri, 2006-12-08 at 16:14 -0800, Fenghua Yu wrote:
> > +		dbr6		: 1,
> > +		reserved	: 48;
> > +} resources_t;
> Is it better to move above definitions to file include/asm-ia64/pal.h?
> 
I'm trying to have the kernel driver as simple as possible and leave the complexity to application. Thus the kernel will be smaller, and needs less update. After all the structure of parameters is only useful for this specific procedure and not common structure for other kernel parts.

Currently the driver is dummy; it doesn't know the structure of the paratmers. All it does is to provide a thin interface to call the pal procedure.

By doing this, I hope we may end up to have a few fancy and complicated applications from the community. In the mean time, we have a small and stable kernel driver underneath.

Thanks.

-Fenghua
