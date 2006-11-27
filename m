From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 27 Nov 2006 21:32:05 +0000
Subject: Re: what is the purpose of "CONFIG_DMA_IS_DMA32"?
Message-Id: <Pine.LNX.4.64.0611271330390.3406@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0611271314280.3419@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.64.0611271314280.3419@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Robert P. J. Day" <rpjday@mindspring.com>
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Mon, 27 Nov 2006, Robert P. J. Day wrote:

> 
>   perhaps a silly question, but:
> 
> $ grep -r "DMA_IS_DMA32" *
> arch/ia64/defconfig:CONFIG_DMA_IS_DMA32=y
> arch/ia64/configs/sim_defconfig:CONFIG_DMA_IS_DMA32=y
> arch/ia64/configs/zx1_defconfig:CONFIG_DMA_IS_DMA32=y
> arch/ia64/configs/tiger_defconfig:CONFIG_DMA_IS_DMA32=y
> arch/ia64/configs/bigsur_defconfig:CONFIG_DMA_IS_DMA32=y
> arch/ia64/configs/gensparse_defconfig:CONFIG_DMA_IS_DMA32=y
> $
> 
> what is the purpose of a configuration symbol that is set but never
> involved in a conditional check?
> 
>   i'm guessing that used to be a config setting in the ia64/Kconfig
> file that has since vanished.

Correct that config setting was eliminated in the 2.6.19 development 
cycle. Refreshing the config files would be advisable.
5A
