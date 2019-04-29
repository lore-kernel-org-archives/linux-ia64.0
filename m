From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 29 Apr 2019 16:16:34 +0000
Subject: Re: serial drivers polishing
Message-Id: <7471c418-4058-db7b-b2ed-af9a67fff201@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-1-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

Hi,

On 04/27/2019 12:51 PM, Enrico Weigelt, metux IT consult wrote:
> Hello folks,
> 
> 
> here's another attempt of polishing the serial drivers:
> 
> * lots of minor cleanups to make checkpatch happier
>    (eg. formatting, includes, inttypes, ...)
> 
> * use appropriate logging helpers instead of printk()
> 
> * consequent use of mapsize/mapbase fields:
>    the basic idea is, all drivers should fill mapbase/mapbase fields at
>    init time and later only use those fields, instead of hardcoded values
>    (later on, we can add generic helpers for the map/unmap stuff, etc)
> 
> * untwisting serial8250_port_size() at all:
>    move the iomem size probing to initialization time, move out some
>    platform specific magic to corresponding platform code, etc.
> 
> 
> Unfortunately, I don't have the actual hardware to really test all
> the code, so please let me know if there's something broken in here.
> 
> 
> have fun,
> 
> --mtx
> 


Got the following build  error while compiling for my powerpc board with 
your full series applied. No time to investigate though.

   CC      arch/powerpc/kernel/setup-common.o
In file included from ./include/linux/serial_8250.h:14:0,
                  from arch/powerpc/kernel/setup-common.c:33:
./include/linux/serial_core.h: In function ‘uart_memres_set_res’:
./include/linux/serial_core.h:446:18: error: ‘resource’ undeclared 
(first use in this function)
    port->iobase = resource->start;
                   ^
./include/linux/serial_core.h:446:18: note: each undeclared identifier 
is reported only once for each function it appears in
./include/linux/serial_core.h:450:2: error: ‘uart’ undeclared (first use 
in this function)
   uart->mapbase = res->start;
   ^
./include/linux/serial_core.h: In function ‘uart_memres_set_start_len’:
./include/linux/serial_core.h:464:6: error: ‘struct uart_driver’ has no 
member named ‘mapbase’
   uart->mapbase = start;
       ^
./include/linux/serial_core.h:465:6: error: ‘struct uart_driver’ has no 
member named ‘mapsize’
   uart->mapsize = len;
       ^
./include/linux/serial_core.h:466:6: error: ‘struct uart_driver’ has no 
member named ‘iotype’
   uart->iotype  = UPIO_MEM;
       ^
make[3]: *** [arch/powerpc/kernel/setup-common.o] Error 1


Christophe
