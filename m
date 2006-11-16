From: Alan <alan@lxorguk.ukuu.org.uk>
Date: Thu, 16 Nov 2006 11:08:21 +0000
Subject: Re: [patch 4/4] ia64: fix allmodconfig build
Message-Id: <20061116110821.6b819120@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
In-Reply-To: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> diff -puN drivers/ide/Kconfig~ia64-fix-allmodconfig-build drivers/ide/Kconfig
> --- a/drivers/ide/Kconfig~ia64-fix-allmodconfig-build
> +++ a/drivers/ide/Kconfig
> @@ -486,6 +486,7 @@ config WDC_ALI15X3
>  
>  config BLK_DEV_AMD74XX
>  	tristate "AMD and nVidia IDE support"
> +	depends on X86
>  	help
>  	  This driver adds explicit support for AMD-7xx and AMD-8111 chips
>  	  and also for the nVidia nForce chip.  This allows the kernel to


NAK this part. The AMD74xx chipset also supports Alpha. I've no idea what
the situation is with the Nvidia parts. It also goes against the general
policy of building everything that can be built on each platform so as to
find bugs/portability problems early.

Alan
