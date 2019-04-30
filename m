From: Vladimir Zapolskiy <vz@mleia.com>
Date: Tue, 30 Apr 2019 20:52:58 +0000
Subject: Re: [PATCH 41/41] drivers: tty: serial: lpc32xx_hs: fill mapsize and use it
Message-Id: <3cfc4396-b152-e9a6-bf29-a4c901ac90e6@mleia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-42-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-42-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

Hi Enrico,

On 04/27/2019 03:52 PM, Enrico Weigelt, metux IT consult wrote:
> Fill the struct uart_port->mapsize field and use it, insteaf of

typo, s/insteaf/instead/

> hardcoded values in many places. This makes the code layout a bit
> more consistent and easily allows using generic helpers for the
> io memory handling.
> 
> Candidates for such helpers could be eg. the request+ioremap and
> iounmap+release combinations.
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>

Acked-by: Vladimir Zapolskiy <vz@mleia.com>

--
Best wishes,
Vladimir
