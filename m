From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 29 Apr 2019 15:21:57 +0000
Subject: Re: [PATCH 15/41] drivers: tty: serial: uartlite: fix use fix bare 'unsigned'
Message-Id: <87ef5krg4q.fsf@dell.be.48ers.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
        <1556369542-13247-16-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-16-git-send-email-info@metux.net> (Enrico
        Weigelt's message of "Sat, 27 Apr 2019 14:51:56 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

>>>>> "Enrico" = Enrico Weigelt, metux IT consult <info@metux.net> writes:

 > Fix checkpatch warnings:
 >     WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
 >     #562: FILE: drivers/tty/serial/uartlite.c:562:
 >     +	unsigned retries = 1000000;

 >     WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
 >     #574: FILE: drivers/tty/serial/uartlite.c:574:
 >     +				 const char *s, unsigned n)

s/fix use fix/fix use of/ in Subject. Other than that:

Acked-by: Peter Korsgaard <peter@korsgaard.com>

-- 
Bye, Peter Korsgaard
