From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Date: Mon, 06 Apr 2015 01:36:37 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <0838dec2-0adf-4e5e-a26c-f0752a0fd2f9@BL2FFO11FD031.protection.gbl>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
 <1428258294.2775.69.camel@perches.com>
In-Reply-To: <1428258294.2775.69.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Joe Perches <joe@perches.com>
Cc: linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, Stefan Agner <stefan@agner.ch>, Patrice Chotard <patrice.chotard@st.com>, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, "Maciej W. Rozycki" <macro@linux-mips.org>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Jiri Slaby <jslaby@suse.cz>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>, linux-tegra@vger.kernel.org, David Brown <davidb@codeau>

On Sun, 2015-04-05 at 11:24AM -0700, Joe Perches wrote:
> These structs can be const, so make them const.
> 
> Miscellanea:
> 
> o Add static to struct uart_ops declaration in bfin_sport_uart
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
[...]

For:
>  drivers/tty/serial/xilinx_uartps.c          | 2 +-

Tested-by: Sören Brinkmann <soren.brinkmann@xilinx.com>

	Sören
