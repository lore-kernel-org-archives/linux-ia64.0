From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 09:43:13 +0000
Subject: Re: [PATCH 40/41] drivers: tty: serial: helper for setting mmio range
Message-Id: <d0b966eb-46b7-d145-92ed-3c62c495f41b@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-41-git-send-email-info@metux.net>
 <87ef5lz423.fsf@haabendal.dk>
In-Reply-To: <87ef5lz423.fsf@haabendal.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Esben Haabendal <esben@haabendal.dk>, "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 29.04.19 09:03, Esben Haabendal wrote:

> Why not simply replace iobase, mapbase and mapsize with a struct
> resource value instead?

That was actually my original goal, when I started this. But the
situation is a bit more tricky. Many drivers (especially the old ones)
initialize these fields in different ways. And there're many places
accessing these fields.

Drivers for old devices should be handled w/ great care. I don't have
access to all that hardware, so I can't test it. Therefore, I'm trying
to move in small steps. One step ahead another.

One of my next steps would be factoring out more common operations
(eg. mapping, etc) into helpers, up to a point, where someday no driver
is accessing these fields directly anymore.

Then we could easily move everything into struct resource. On that
road, we'd also need to find a way for handling the specialities of
the various UPIO_* modes via struct resource.


--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
