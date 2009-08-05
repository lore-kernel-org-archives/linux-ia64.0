From: Neil Horman <nhorman@redhat.com>
Date: Wed, 05 Aug 2009 13:41:02 +0000
Subject: Re: [Patch 1/7] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <20090805134102.GD7259@hmsreliant.think-freely.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <20090805112133.6552.69619.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112133.6552.69619.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

On Wed, Aug 05, 2009 at 07:19:12AM -0400, Amerigo Wang wrote:
> 
> Introduce a new config option KEXEC_AUTO_RESERVE for x86.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
> Index: linux-2.6/arch/x86/Kconfig
> =================================> --- linux-2.6.orig/arch/x86/Kconfig
> +++ linux-2.6/arch/x86/Kconfig
> @@ -1482,6 +1482,16 @@ config KEXEC
>  	  support.  As of this writing the exact hardware interface is
>  	  strongly in flux, so no good recommendation can be made.
>  
> +config KEXEC_AUTO_RESERVE
> +	bool "automatically reserve memory for kexec kernel"
> +	depends on KEXEC
> +	default y
> +	---help---
> +	  Automatically reserve memory for a kexec kernel, so that you don't
> +	  need to specify numbers for the "crashkernel=X@Y" boot option,
> +	  instead you can use "crashkernel=auto".
> +	  On x86, 128M is reserved.
> +
>  config CRASH_DUMP
>  	bool "kernel crash dumps"
>  	depends on X86_64 || (X86_32 && HIGHMEM)

Acked-by: Neil Horman <nhorman@tuxdriver.com>

