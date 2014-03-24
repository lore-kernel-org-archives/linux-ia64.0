From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Mon, 24 Mar 2014 05:47:06 +0000
Subject: Re: [RESEND][PATCH 1/2] lib/scatterlist: Make ARCH_HAS_SG_CHAIN an actual Kconfig
Message-Id: <20140324054706.GA4487@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395512032-20575-1-git-send-email-lauraa@codeaurora.org>
 <1395512032-20575-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1395512032-20575-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "James E.J. Bottomley" <JBottomley@parallels.com>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux390@de.ibm.com, linux-arm-kernel@lists.infradead.org

On Sat, Mar 22, 2014 at 11:13:51AM -0700, Laura Abbott wrote:
> Rather than have architectures #define ARCH_HAS_SG_CHAIN in an architecture
> specific scatterlist.h, make it a proper Kconfig option and use that
> instead. At same time, remove the header files are are now mostly
> useless and just include asm-generic/scatterlist.h.
> 

[...]

> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index 65a0775..d6c2059 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -142,6 +142,7 @@ config S390
>  	select SYSCTL_EXCEPTION_TRACE
>  	select VIRT_CPU_ACCOUNTING
>  	select VIRT_TO_BUS
> +	select ARCH_HAS_SG_CHAIN
> 

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

FWIW, it would have been nice to keep the list of selected configs sorted.
However no need to resend.

