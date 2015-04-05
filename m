From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 05 Apr 2015 22:23:10 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct uart_ops declarations
Message-Id: <alpine.LFD.2.11.1504052319340.21028@eddie.linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
 <1428258294.2775.69.camel@perches.com>
In-Reply-To: <1428258294.2775.69.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: linux-ia64@vger.kernel.org, kernel@stlinux.com, Nicolas Ferre <nicolas.ferre@atmel.com>, Timur Tabi <timur@tabi.org>, Stefan Agner <stefan@agner.ch>, Patrice Chotard <patrice.chotard@st.com>, Pat Gefre <pfg@sgi.com>, Laxman Dewangan <ldewangan@nvidia.com>, Daniel Walker <dwalker@fifo99.com>, sparclinux@vger.kernel.org, Peter Korsgaard <jacmet@sunsite.dk>, Sonic Zhang <sonic.zhang@analog.com>, Jiri Slaby <jslaby@suse.cz>, Alexandre Courbot <gnurou@gmail.com>, Russell King <linux@arm.linux.org.uk>, Michal Simek <michal.simek@xilinx.com>, =?ISO-8859-15?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>, linux-serial@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>, Stephen Warren <swarren@wwwdotorg.org>, linux-arm-msm@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>, linux-tegra@vger.kernel.org, Dav

On Sun, 5 Apr 2015, Joe Perches wrote:

>  drivers/tty/serial/dz.c                     | 2 +-
>  drivers/tty/serial/zs.c                     | 2 +-

 For these verified that the change works correctly, thanks for your work.

Acked-by: Maciej W. Rozycki <macro@linux-mips.org>

  Maciej
