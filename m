From: Thierry Reding <thierry.reding@gmail.com>
Date: Thu, 09 Apr 2015 09:48:28 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <20150409094827.GI12103@ulmo>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mhOzvPhkurUs4vA9"
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
 <1428258294.2775.69.camel@perches.com>
In-Reply-To: <1428258294.2775.69.camel@perches.com>
To: Joe Perches <joe@perches.com>
Cc: Stefan Agner <stefan@agner.ch>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, linux-kernel@vger.kernel.org, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, "Maciej W. Rozycki" <macro@linux-mips.org>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, linux-arm-kernel@lists.infradead.org, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cas>


--mhOzvPhkurUs4vA9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Apr 05, 2015 at 11:24:54AM -0700, Joe Perches wrote:
[...]
>  drivers/tty/serial/serial-tegra.c           | 2 +-

Acked-by: Thierry Reding <treding@nvidia.com>

--mhOzvPhkurUs4vA9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVJkrqAAoJEN0jrNd/PrOh45MP/3gSYsW+iLTl6x31M/1w3yG5
Bbh0OsyQ9lCEtTmbpLR0fLf8G7p5BonsghFrt98B0rzRBMwnXGhE5/9p0daLOE3K
3tyu2w1OAxcXuOatR8SDWkXex/lNLvNxDKUMPDvrvJtI5zVrfIRsG7FTp7zQkupV
jWGCR9j59RFkLAyz1A0avgCbOGl11xVin1d+EUD2ZCrTwxl5FiuV2Ar2E7/7hh04
NsghKA4FLAfZZiyYJ5Lc+7VHqqlk5araKzUOHee1eKi19ntmC6PYbYz2dbMEzcCt
xpKUEe7jrIqhqZjWfOws6GWUy5GTN8zrxlqPjf1D9wWX8bVUK5/n2wQYTrf91exg
3K668MqIYosS044FhFSu+0hXq42Q4BcsMlI9SLjJaVvjs/9uUuXdCtKO0tHN4qfj
9SbgPQ5eKCVX23VJX5BsKD8RxhxSAes5ELi851yvtap7SUSF8QQ5IUp8BZ6Wk5iD
1/F1ZmCggM0BHK5uOE1Omv8t2/Mvj/7vNXzU6uHxl7iPKe6lmVEJQkwrH+qzwtWL
heunoQ0JmW+vsbkJsJdia23ybd6im3RUszQ1no1IBJqUeG8QuGFUAcNcad4H931m
EocSXdQJqiDb82MgylCRfPrwL5s4YpAF+xaVeMm75CWwKXGP1aaywXLbkW40JVWj
C/WJI66kI+i093rg6DmD
=7FoG
-----END PGP SIGNATURE-----

--mhOzvPhkurUs4vA9--
