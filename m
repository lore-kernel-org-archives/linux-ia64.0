From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 14:55:05 +0000
Subject: Re: [PATCH 36/41] drivers: tty: serial: 8250: store mmio resource size in port struct
Message-Id: <4bab941a-c2f2-7f1c-9bc2-86c63f171c25@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-37-git-send-email-info@metux.net>
 <20190428151848.GO9224@smile.fi.intel.com>
In-Reply-To: <20190428151848.GO9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 28.04.19 17:18, Andy Shevchenko wrote:
> On Sat, Apr 27, 2019 at 02:52:17PM +0200, Enrico Weigelt, metux IT consult wrote:
>> The io resource size is currently recomputed when it's needed but this
>> actually needs to be done once (or drivers could specify fixed values)
> 
> io -> IO

fixed.

>> Simplify that by doing this computation only once and storing the result
>> into the mapsize field. serial8250_register_8250_port() is now called
>> only once on driver init, the previous call sites now just fetch the
>> value from the mapsize field.
> 
> Do I understand correctly that this has no side effects?

I don't know of any. (except someting changes things like regshift after
the initialization phase ... :o)

>> @@ -979,6 +979,9 @@ int serial8250_register_8250_port(struct uart_8250_port *up)
>>  	if (up->port.uartclk = 0)
>>  		return -EINVAL;
>>  
>> +	/* compute the mapsize in case the driver didn't specify one */
>> +	up->mapsize = serial8250_port_size(up);
> 
> I don't know all quirks in 8250 drivers by heart, though can you guarantee that
> at this point the device reports correct IO resource size? (If I'm not mistaken
> some broken hardware needs some magic to be done before card can be properly
> handled)

Actually, I don't see anything talking to the hardware at all here.
It's all derived from values that are set up before
serial8250_register_8250_port() is called.

>> -	unsigned int size = serial8250_port_size(up);
>>  	struct uart_port *port = &up->port;
> 
>> -	int ret = 0;
> 
> This and Co is a separate change that can be done in its own patch.

I don't really understand :(
Do you mean the splitting off the retval part from the rest ?

>> +			port->membase = ioremap_nocache(port->mapbase,
>> +							port->mapsize);
> 
> You may increase readability by introducing temporary variables
> 
> 	... mapbase = port->mapbase;
> 	... mapsize = port->mapsize;
> 	...
> 	port->membase = ioremap_nocache(mapbase, mapsize);
> 	...

Is that really necessary ? Maybe it's just my personal taste, but I
don't feel the more more verbose one is really easier to read.

--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
