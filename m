From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 29 Apr 2019 15:19:57 +0000
Subject: Re: [PATCH 13/41] drivers: tty: serial: uartlite: fill mapsize and use it
Message-Id: <87muk8rg82.fsf@dell.be.48ers.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
        <1556369542-13247-14-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-14-git-send-email-info@metux.net> (Enrico
        Weigelt's message of "Sat, 27 Apr 2019 14:51:54 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

>>>>> "Enrico" = Enrico Weigelt, metux IT consult <info@metux.net> writes:

 > Fill the struct uart_port->mapsize field and use it, insteaf of

s/insteaf/instead/

 > hardcoded values in many places. This makes the code layout a bit
 > more consistent and easily allows using generic helpers for the
 > io memory handling.

 > Candidates for such helpers could be eg. the request+ioremap and
 > iounmap+release combinations.

 > Signed-off-by: Enrico Weigelt <info@metux.net>

Acked-by: Peter Korsgaard <peter@korsgaard.com>

-- 
Bye, Peter Korsgaard
