From: Joe Perches <joe@perches.com>
Date: Mon, 06 Apr 2015 00:16:14 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <1428279374.2775.78.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
	 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
	 <1428258294.2775.69.camel@perches.com>
	 <d55b1a1240db66ae651cb99cd713694a@agner.ch>
In-Reply-To: <d55b1a1240db66ae651cb99cd713694a@agner.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefan Agner <stefan@agner.ch>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, linux-kernel@vger.kernel.org, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, "Maciej W. Rozycki" <macro@linux-mips.org>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, linux-arm-kernel@lists.infradead.org, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>, linux

On Mon, 2015-04-06 at 01:09 +0200, Stefan Agner wrote:
> On 2015-04-05 20:24, Joe Perches wrote:
> > Still compiled only x86 and not cross-compiled or tested.
> 
> Cross-compiled with multi_v7_defconfig
[]
> >  drivers/tty/serial/fsl_lpuart.c             | 4 ++--
> 
> Tested that driver on actual hardware, looks fine.

> This driver seems to alter the startup function on initialization:
> 
>   CC      drivers/video/of_display_timing.o
> ../drivers/tty/serial/samsung.c: In function 's3c24xx_serial_init_port':
> ../drivers/tty/serial/samsung.c:1702:3: error: assignment of member
> 'startup' in read-only object
>    s3c24xx_serial_ops.startup = s3c64xx_serial_startup;
>    ^

Thanks Stefan.  Then that one can't be const.

> That is the only thing which popped up with multi_v7_defconfig.

I appreciate the testing.

Greg, Jiri, I'll resend with this fixed in a week or so
after waiting for any other comment or sign of brokenness.


