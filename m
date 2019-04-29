From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 29 Apr 2019 13:12:24 +0000
Subject: Re: [PATCH 01/41] drivers: tty: serial: dz: use dev_err() instead of printk()
Message-Id: <20190429131224.GA27385@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-2-git-send-email-info@metux.net>
 <20190427133117.GC11368@kroah.com>
 <bae3f23b-8823-f089-c40e-024ba225555f@metux.net>
In-Reply-To: <bae3f23b-8823-f089-c40e-024ba225555f@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Mon, Apr 29, 2019 at 02:37:04PM +0200, Enrico Weigelt, metux IT consult wrote:
> On 27.04.19 15:31, Greg KH wrote:
> > On Sat, Apr 27, 2019 at 02:51:42PM +0200, Enrico Weigelt, metux IT consult wrote:
> >> Using dev_err() instead of printk() for more consistent output.
> >> (prints device name, etc).
> >>
> >> Signed-off-by: Enrico Weigelt <info@metux.net>
> >> ---
> >>  drivers/tty/serial/dz.c | 8 ++++----
> > 
> > Do you have this hardware to test any of these changes with?
> 
> Unfortunately not :(

Then I can take the "basic" types of patches for the driver (like this
one), but not any others, sorry.

thanks,

greg k-h
