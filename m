From: Jes Sorensen <jes@sgi.com>
Date: Mon, 30 Jul 2007 07:40:17 +0000
Subject: Re: [PATCH] ia64: Remove a few duplicate includes
Message-Id: <46AD95E1.6020100@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200707300028.42496.jesper.juhl@gmail.com>
In-Reply-To: <200707300028.42496.jesper.juhl@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-altix@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Jesper Juhl wrote:
> (sorry about the duplicate mail, forgot a recipient first time)
> 
> Hi,
> This patch removes a few duplicate includes from arch/ia64/
> Please consider merging :-)
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

sn2/Altix portion is fine with me, so.

Acked-by: Jes Sorensen <jes@sgi.com>

> ---
> 
>  arch/ia64/ia32/sys_ia32.c   |    1 -
>  arch/ia64/kernel/setup.c    |    1 -
>  arch/ia64/sn/kernel/setup.c |    1 -
>  3 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
> index af10462..a3405b3 100644
> --- a/arch/ia64/ia32/sys_ia32.c
> +++ b/arch/ia64/ia32/sys_ia32.c
> @@ -34,7 +34,6 @@
>  #include <linux/uio.h>
>  #include <linux/nfs_fs.h>
>  #include <linux/quota.h>
> -#include <linux/syscalls.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/cache.h>
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index 7cecd29..cd9a37a 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -60,7 +60,6 @@
>  #include <asm/smp.h>
>  #include <asm/system.h>
>  #include <asm/unistd.h>
> -#include <asm/system.h>
>  
>  #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
>  # error "struct cpuinfo_ia64 too big!"
> diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
> index 684b1c9..1f38a3a 100644
> --- a/arch/ia64/sn/kernel/setup.c
> +++ b/arch/ia64/sn/kernel/setup.c
> @@ -25,7 +25,6 @@
>  #include <linux/interrupt.h>
>  #include <linux/acpi.h>
>  #include <linux/compiler.h>
> -#include <linux/sched.h>
>  #include <linux/root_dev.h>
>  #include <linux/nodemask.h>
>  #include <linux/pm.h>
> 

