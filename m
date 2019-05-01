From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Wed, 01 May 2019 02:20:37 +0000
Subject: Re: [PATCH 01/41] drivers: tty: serial: dz: use dev_err() instead of printk()
Message-Id: <alpine.LFD.2.21.1905010255070.30973@eddie.linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net> <1556369542-13247-2-git-send-email-info@metux.net> <20190427133117.GC11368@kroah.com> <bae3f23b-8823-f089-c40e-024ba225555f@metux.net> <20190429131224.GA27385@kroah.com>
In-Reply-To: <20190429131224.GA27385@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "Enrico Weigelt, metux IT consult" <lkml@metux.net>, "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, "David S. Miller" <davem@davemloft.net>, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Mon, 29 Apr 2019, Greg KH wrote:

> > >>  drivers/tty/serial/dz.c | 8 ++++----
> > > 
> > > Do you have this hardware to test any of these changes with?
> > 
> > Unfortunately not :(
> 
> Then I can take the "basic" types of patches for the driver (like this
> one), but not any others, sorry.

 I can verify changes to dz.c, sb1250-duart.c and zs.c with real hardware, 
but regrettably not right away: the hardware is in a remote location and 
while I have it wired for remote operation unfortunately its connectivity 
has been cut off by an unfriendly ISP.

 I'm not sure if all the changes make sense though: if there is a compiler 
warning or a usability issue, then a patch is surely welcome, otherwise: 
"If it ain't broke, don't fix it".

  Maciej
