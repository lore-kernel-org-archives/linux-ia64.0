From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 18:26:51 +0000
Subject: Re: [PATCH 13/41] drivers: tty: serial: uartlite: fill mapsize and use it
Message-Id: <cb01328c-6308-d9c7-17ba-644d983b0a50@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-14-git-send-email-info@metux.net>
 <87muk8rg82.fsf@dell.be.48ers.dk>
In-Reply-To: <87muk8rg82.fsf@dell.be.48ers.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Korsgaard <peter@korsgaard.com>, "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

On 29.04.19 17:19, Peter Korsgaard wrote:
>>>>>> "Enrico" = Enrico Weigelt, metux IT consult <info@metux.net> writes:
> 
>  > Fill the struct uart_port->mapsize field and use it, insteaf of
> 
> s/insteaf/instead/

Fixed.

>  > hardcoded values in many places. This makes the code layout a bit
>  > more consistent and easily allows using generic helpers for the
>  > io memory handling.
> 
>  > Candidates for such helpers could be eg. the request+ioremap and
>  > iounmap+release combinations.
> 
>  > Signed-off-by: Enrico Weigelt <info@metux.net>
> 
> Acked-by: Peter Korsgaard <peter@korsgaard.com>

thanks for review.


--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
