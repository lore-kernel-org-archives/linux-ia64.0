From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 16 Mar 2004 17:37:43 +0000
Subject: Re: [PATCH] Update SN2 defconfig
Message-Id: <20040316173743.GA29899@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040315190240.GY6699@localhost>
In-Reply-To: <20040315190240.GY6699@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 15, 2004 at 10:14:20PM -0800, David Mosberger wrote:
> >>>>> On Mon, 15 Mar 2004 11:05:39 -0800, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   >> CONFIG_MAGIC_SYSRQ=y -CONFIG_IA64_EARLY_PRINTK=y -#
>   >> CONFIG_IA64_EARLY_PRINTK_UART is not set -#
>   >> CONFIG_IA64_EARLY_PRINTK_VGA is not set
>   >> -CONFIG_IA64_EARLY_PRINTK_SGI_SN=y
> 
>   Jesse> Oops, we don't want to lose early printk from the config...
>   Jesse> Looks ok otherwise, thanks for sending it.
> 
> The ia64 EARLY_PRINTK support is not part of the official kernel, so
> they should be lost to avoid warnings (if someone wanted to integrate
> the ia64 EARLY_PRINTK patch with the other early-printk support in the
> kernel, that would certainly be welcome, though).

Well, I was hoping to just have one sn2_defconfig file that was shared
between the linux-ia64-2.5 tree and the to-linus-2.5 tree; that way I'd
get early printk automatically if I applied the ia64 patch.  I didn't
think that was a problem (I haven't seen any warnings when I do 'make
sn2_defconfig' out of Linus' tree), but of course ideally we'd have
early printk for ia64 in Linus' tree, so I'm looking forward to Bjorn's
patch.

Thanks,
Jesse
