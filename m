From: Grant Grundler <iod00d@hp.com>
Date: Tue, 22 Jun 2004 14:51:23 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <20040622145123.GA25536@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 22, 2004 at 09:50:10AM -0400, Jesse Barnes wrote:
> Did you have any MCA records after you rebooted?

Sorry - I forgot to mention that. I did check and there was none.

> This is about the time it should have chosen a default console device
> and started printing to it, so if it tried using the VGA console and
> you didn't have one, it may have just fallen over.
> The MCA record would be pretty clear about that though...

I was thinking it just picked a different serial port for ttyS0 output.
That's why I waited a couple of minutes to see if I could
ping/ssh to the box. But after two minutes it still didn't
respond and should have by then.

The systems does have a VGA output but nothing is connected.
USB keyboard/mouse is not connected either.

However, you just gave me the idea to enable CONFIG_IA64_EARLY_PRINTK.
Trying that now.

thanks,
grant

> 
> Jesse
