From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 29 Apr 2019 15:39:49 +0000
Subject: Re: [PATCH 36/41] drivers: tty: serial: 8250: store mmio resource size in port struct
Message-Id: <20190429153949.GV9224@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-37-git-send-email-info@metux.net>
 <20190428151848.GO9224@smile.fi.intel.com>
 <4bab941a-c2f2-7f1c-9bc2-86c63f171c25@metux.net>
In-Reply-To: <4bab941a-c2f2-7f1c-9bc2-86c63f171c25@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Mon, Apr 29, 2019 at 04:55:05PM +0200, Enrico Weigelt, metux IT consult wrote:
> On 28.04.19 17:18, Andy Shevchenko wrote:
> > On Sat, Apr 27, 2019 at 02:52:17PM +0200, Enrico Weigelt, metux IT consult wrote:

> >> -	int ret = 0;
> > 
> > This and Co is a separate change that can be done in its own patch.
> 
> I don't really understand :(
> Do you mean the splitting off the retval part from the rest ?

You do two things here: one of them is removing ret and other relative changes.
This should be split to a separate patch.

> > You may increase readability by introducing temporary variables
> > 
> > 	... mapbase = port->mapbase;
> > 	... mapsize = port->mapsize;
> > 	...
> > 	port->membase = ioremap_nocache(mapbase, mapsize);
> > 	...
> 
> Is that really necessary ? Maybe it's just my personal taste, but I
> don't feel the more more verbose one is really easier to read.

Up to Greg. For me it's harder to read all those port-> in several parameters.


-- 
With Best Regards,
Andy Shevchenko

