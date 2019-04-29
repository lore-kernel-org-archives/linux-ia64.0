From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 29 Apr 2019 15:58:54 +0000
Subject: Re: [PATCH 37/41] drivers: tty: serial: 8250: simplify io resource size computation
Message-Id: <7cec8c1a-a0a1-e76c-5c1f-a93c591d38b1@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-38-git-send-email-info@metux.net>
 <ba6dd5fa-36f1-902d-1ab4-c99e6a5ea3c2@physik.fu-berlin.de>
In-Reply-To: <ba6dd5fa-36f1-902d-1ab4-c99e6a5ea3c2@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 27.04.19 15:03, John Paul Adrian Glaubitz wrote:
> On 4/27/19 2:52 PM, Enrico Weigelt, metux IT consult wrote:
>> Simpily io resource size computation by setting mapsize field.
>     ^^^^
> Here's a typo

thx. fixed.

--mtx


-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
