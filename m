From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 15 Mar 2004 19:05:39 +0000
Subject: Re: [PATCH] Update SN2 defconfig
Message-Id: <20040315190539.GA4869@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040315190240.GY6699@localhost>
In-Reply-To: <20040315190240.GY6699@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  CONFIG_MAGIC_SYSRQ=y
> -CONFIG_IA64_EARLY_PRINTK=y
> -# CONFIG_IA64_EARLY_PRINTK_UART is not set
> -# CONFIG_IA64_EARLY_PRINTK_VGA is not set
> -CONFIG_IA64_EARLY_PRINTK_SGI_SN=y

Oops, we don't want to lose early printk from the config...  Looks ok
otherwise, thanks for sending it.

Jesse
