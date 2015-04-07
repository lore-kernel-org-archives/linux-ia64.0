From: Patrice Chotard <patrice.chotard@st.com>
Date: Tue, 07 Apr 2015 07:14:10 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <552383C2.3050502@st.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>	 <a938a0e86638588e5ccff85771fa3b95@agner.ch> <1428258294.2775.69.camel@perches.com>
In-Reply-To: <1428258294.2775.69.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, Stefan Agner <stefan@agner.ch>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, linux-kernel@vger.kernel.org, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, "Maciej W. Rozycki" <macro@linux-mips.org>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, linux-arm-kernel@lists.infradead.org, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cascardo@linux.vnet>

Hi

On 04/05/2015 08:24 PM, Joe Perches wrote:
> These structs can be const, so make them const.
>
> Miscellanea:
>
> o Add static to struct uart_ops declaration in bfin_sport_uart
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
[...]

for
>   drivers/tty/serial/st-asc.c                 | 2 +-

Acked-by: Patrice Chotard <patrice.chotard@st.com>


Thanks


