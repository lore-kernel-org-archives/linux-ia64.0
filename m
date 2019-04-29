From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 29 Apr 2019 14:23:21 +0000
Subject: Re: [PATCH 01/41] drivers: tty: serial: dz: use dev_err() instead of printk()
Message-Id: <20190429142321.GA29007@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-2-git-send-email-info@metux.net>
 <20190427132959.GA11368@kroah.com>
 <e10175d0-bc3b-a4ab-cb47-0b4761bfb629@metux.net>
In-Reply-To: <e10175d0-bc3b-a4ab-cb47-0b4761bfb629@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Mon, Apr 29, 2019 at 04:11:15PM +0200, Enrico Weigelt, metux IT consult wrote:
> On 27.04.19 15:29, Greg KH wrote:
> > On Sat, Apr 27, 2019 at 02:51:42PM +0200, Enrico Weigelt, metux IT consult wrote:
> >> Using dev_err() instead of printk() for more consistent output.
> >> (prints device name, etc).
> >>
> >> Signed-off-by: Enrico Weigelt <info@metux.net>
> > 
> > Your "From:" line does not match the signed-off-by line, so I can't take
> > any of these if I wanted to :(
> 
> Grmpf. I've manually changed it, as you isisted in having my company
> name remove from it ....

Yes, that's fine, but the lines have to match.  See the documentation
for how to have a "From:" in the changelog text to override whatever
your email client happens to pollute the email with :)

thanks,

greg k-h
