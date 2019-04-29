From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 10:12:35 +0000
Subject: Re: [PATCH 40/41] drivers: tty: serial: helper for setting mmio range
Message-Id: <c75f4ca9-367c-25d5-2597-75f2dccf6e1c@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-41-git-send-email-info@metux.net>
 <20190428153905.GR9224@smile.fi.intel.com>
In-Reply-To: <20190428153905.GR9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 28.04.19 17:39, Andy Shevchenko wrote:

Hi,

seems I've forgot to add "RFC:" in the subject - I'm not entirely happy
w/ that patch myself, just want to hear your oppinions.

>> -	port->port.iotype = UPIO_MEM;>> -	port->port.mapbase = pci_resource_start(pcidev, bar) + offset;>> +
uart_memres_set_start_len(&port->port,>> +				
pci_resource_start(pcidev, bar) + offset,>> +				
pci_resource_len(pcidev, bar));>> +> > I don't see how it's better.>
Moreover, the size argument seems wrong here.
hmm, I'm actually not sure yet, what the correct size really would be,
where the value actually comes from. Just assumed that it would be the
whole area that the BAR tells. But now I recognized that I'd need to
substract 'offset' here.

Rethinking it further, we'd probably could deduce the UPIO_* from the
struct resource, too.

>> +		uart_memres_set_start_len(>> +			&port,>> +			FRODO_BASE + FRODO_APCI_OFFSET(1), 0);> > Please,
avoid such splitting, first parameter is quite fit above line.

Ok. My intention was having both parameters starting at the same line,
but then the second line would get too long again. > ...and here, and
maybe in other places you split the assignments to the members> in two
part. Better to call your function before or after these blocks of>
assignments.
the reason what I've just replaced the exactly the assignments, trying
not to touch too much ;-)
I'll have a closer look on what can be moved w/o side effects.

>> -			uport->mapsize	= ZS_CHAN_IO_SIZE;
>> -			uport->mapbase	= dec_kn_slot_base +
>> -					  zs_parms.scc[chip] +
>> -					  (side ^ ZS_CHAN_B) * ZS_CHAN_IO_SIZE;
>> +
>> +			uart_memres_set_start_len(dec_kn_slot_base +
>> +						    zs_parms.scc[chip] +
>> +						    (side ^ ZS_CHAN_B) *
>> +							ZS_CHAN_IO_SIZE,
>> +						  ZS_CHAN_IO_SIZE);
> 
> This looks hard to read. Think of temporary variables and better formatting
> style.

Ok.

> 
>>  /*
>> + * set physical io range from struct resource
>> + * if resource is NULL, clear the fields
>> + * also set the iotype to UPIO_MEM
> 
> Something wrong with punctuation and style. Please, use proper casing and
> sentences split.

Ok. fixed it.


>> +static inline void uart_memres_set_res(struct uart_port *port,
> 
> Perhaps better name can be found.
> Especially taking into account that it handles IO / MMIO here.

hmm, lacking creativity here ;-)
any suggestions ?

> 
>> +				       struct resource *res)
>> +{
>> +	if (!res) {
> 
> It should return an error in such case.

It's not an error, but desired behaviour: NULL resource
clears the value.

>> +		port->mapsize = 0;
>> +		port->mapbase = 0;
>> +		port->iobase = 0;
>> +		return;
>> +	}
>> +
>> +	if (resource_type(res) = IORESOURCE_IO) {
>> +		port->iotype = UPIO_PORT;
>> +		port->iobase = resource->start;
>> +		return;
>> +	}
>> +
>> +	uart->mapbase = res->start;
>> +	uart->mapsize = resource_size(res);
> 
>> +	uart->iotype  = UPIO_MEM;
> 
> Only one type? Why type is even set here?

It's the default case. The special cases (eg. UPIO_MEM32) need to be
set explicitly, after that call.

Not really nice, but haven't found a better solution yet. I don't like
the idea of passing an UPIO_* parameter to the function, most callers
should not care, if they don't really need to.


>> + */
> 
>> +static inline void uart_memres_set_start_len(struct uart_driver *uart,
>> +					     resource_size_t start,
>> +					     resource_size_t len)
> 
> The comment doesn't tell why this is needed when we have one for struct
> resource.

Renamed it to uart_memres_set_mmio_range().

This helper is meant for drivers that don't work w/ struct resource,
or explicitly set their own len.



Thanks for your review.

--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
