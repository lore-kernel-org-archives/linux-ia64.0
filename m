From: Ingo Molnar <mingo@kernel.org>
Date: Wed, 21 Aug 2013 07:26:40 +0000
Subject: Re: [PATCH] Kconfig: Remove hotplug enable hints in CONFIG_KEXEC help texts
Message-Id: <20130821072640.GA27495@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377027483-17025-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1377027483-17025-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> commit 40b313608ad4ea655addd2ec6cdd106477ae8e15 ("Finally eradicate
> CONFIG_HOTPLUG") removed remaining references to CONFIG_HOTPLUG, but missed
> a few plain English references in the CONFIG_KEXEC help texts.
> 
> Remove them, too.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  arch/arm/Kconfig     |    3 +--
>  arch/ia64/Kconfig    |    6 +++---
>  arch/mips/Kconfig    |    6 +++---
>  arch/powerpc/Kconfig |    6 +++---
>  arch/sh/Kconfig      |    6 +++---
>  arch/x86/Kconfig     |    6 +++---
>  6 files changed, 16 insertions(+), 17 deletions(-)
[...]
>  	bool "kernel crash dumps (EXPERIMENTAL)"
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index b32ebf9..6ace5de 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1627,9 +1627,9 @@ config KEXEC
>  
>  	  It is an ongoing process to be certain the hardware in a machine
>  	  is properly shutdown, so do not be surprised if this code does not
> -	  initially work for you.  It may help to enable device hotplugging
> -	  support.  As of this writing the exact hardware interface is
> -	  strongly in flux, so no good recommendation can be made.
> +	  initially work for you.  As of this writing the exact hardware
> +	  interface is strongly in flux, so no good recommendation can be
> +	  made.
>  
>  config CRASH_DUMP
>  	bool "kernel crash dumps"

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo
