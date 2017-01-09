From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 09 Jan 2017 11:33:02 +0000
Subject: Re: [PATCH v2 1/7] arm: put types.h in uapi
Message-Id: <1990589.0aJHWbJK4F@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-2-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-2-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@lists.ozlabs.org, linux-kbuild@vger.kernel.org
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.orgli

On Friday, January 6, 2017 10:43:53 AM CET Nicolas Dichtel wrote:
> 
> diff --git a/arch/arm/include/asm/types.h b/arch/arm/include/asm/types.h
> index a53cdb8f068c..c48fee3d7b3b 100644
> --- a/arch/arm/include/asm/types.h
> +++ b/arch/arm/include/asm/types.h
> @@ -1,40 +1,6 @@
>  #ifndef _ASM_TYPES_H
>  #define _ASM_TYPES_H
>  
> -#include <asm-generic/int-ll64.h>
...
> -#define __UINTPTR_TYPE__       unsigned long
> -#endif
> +#include <uapi/asm/types.h>
>  
>  #endif /* _ASM_TYPES_H */
> 

Moving the file is correct as far as I can tell, but the extra
#include is not necessary here, as the kernel will automatically
search both arch/arm/include/ and arch/arm/include/uapi/.

The same applies to patches 2 and 4.

	Arnd
