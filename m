From: Will Deacon <will.deacon@arm.com>
Date: Wed, 02 Mar 2016 02:15:50 +0000
Subject: Re: [PATCH 2/2] numa, mm, cleanup: remove redundant NODE_DATA macro from asm header files.
Message-Id: <20160302021550.GI14022@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456358528-24213-1-git-send-email-ddaney.cavm@gmail.com>
 <1456358528-24213-3-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1456358528-24213-3-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.ker

On Wed, Feb 24, 2016 at 04:02:08PM -0800, David Daney wrote:
> From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> 
> NODE_DATA is defined across multiple asm header files.
> Moving generic definition to asm-generic/mmzone.h to
> remove redundant definitions.
> 
> Reviewed-by: Robert Richter <rrichter@cavium.com>
> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  arch/arm64/include/asm/mmzone.h   |  4 +---
>  arch/m32r/include/asm/mmzone.h    |  4 +---
>  arch/metag/include/asm/mmzone.h   |  4 +---
>  arch/powerpc/include/asm/mmzone.h |  8 ++------
>  arch/s390/include/asm/mmzone.h    |  6 +-----
>  arch/sh/include/asm/mmzone.h      |  4 +---
>  arch/sparc/include/asm/mmzone.h   |  6 ++----
>  arch/x86/include/asm/mmzone.h     |  3 +--
>  arch/x86/include/asm/mmzone_32.h  |  5 -----
>  arch/x86/include/asm/mmzone_64.h  | 17 -----------------
>  include/asm-generic/mmzone.h      | 24 ++++++++++++++++++++++++
>  11 files changed, 34 insertions(+), 51 deletions(-)
>  delete mode 100644 arch/x86/include/asm/mmzone_64.h
>  create mode 100644 include/asm-generic/mmzone.h
> 
> diff --git a/arch/arm64/include/asm/mmzone.h b/arch/arm64/include/asm/mmzone.h
> index a0de9e6..611a1cf 100644
> --- a/arch/arm64/include/asm/mmzone.h
> +++ b/arch/arm64/include/asm/mmzone.h
> @@ -4,9 +4,7 @@
>  #ifdef CONFIG_NUMA
>  
>  #include <asm/numa.h>
> -
> -extern struct pglist_data *node_data[];
> -#define NODE_DATA(nid)		(node_data[(nid)])
> +#include  <asm-generic/mmzone.h>
>  
>  #endif /* CONFIG_NUMA */
>  #endif /* __ASM_MMZONE_H */

Actually, we can remove the header file entirely and use a generic-y
line in Kbuild instead.

Will
