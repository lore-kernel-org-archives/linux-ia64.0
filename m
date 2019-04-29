From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 06:48:53 +0000
Subject: Re: [PATCH 37/41] drivers: tty: serial: 8250: simplify io resource size computation
Message-Id: <431b36fe-3071-fcfd-b04e-b4b293e79a80@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-38-git-send-email-info@metux.net>
 <20190428152103.GP9224@smile.fi.intel.com>
In-Reply-To: <20190428152103.GP9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 28.04.19 17:21, Andy Shevchenko wrote:

> 
>> +#define SERIAL_RT2880_IOSIZE	0x100
> 
> And why this is in the header file and not in corresponding C one?

hmm, no particular reason, maybe just an old habit to put definitions
into .h files ;-)

I can move it to 8250_of.c if you like me to.



--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
