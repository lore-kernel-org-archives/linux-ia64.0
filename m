From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 16 Jan 2004 22:32:09 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <200401161532.09601.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 January 2004 2:39 pm, Peter Chubb wrote:
>  config IA64_HP_ZX1
> -	bool "HP-zx1"
> +	bool "HP"
> 
> Please don't do this.  You'll get people selecting it for the HP
> I2000 and RX4610, which are *not* based on the ZX1 chipset, even
> though they're made by HP.

Yes, you're right.  And the result is particularly ugly -- 
booting an IA64_HP_ZX1 kernel on an i2000 gives no output at
all (at least on a serial console).

We do need something more general than HP-zx1, though.  It
already supports sx1000 as well.  I'll try to think of something.

