From: Neil Horman <nhorman@redhat.com>
Date: Wed, 05 Aug 2009 13:43:42 +0000
Subject: Re: [Patch 2/7] x86: implement crashkernel=auto
Message-Id: <20090805134342.GE7259@hmsreliant.think-freely.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <20090805112142.6552.18373.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112142.6552.18373.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

On Wed, Aug 05, 2009 at 07:19:22AM -0400, Amerigo Wang wrote:
> 
> Implement "crashkernel=auto" for x86 first, other arch will be added in the
> following patches.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
> Index: linux-2.6/kernel/kexec.c
> =================================> --- linux-2.6.orig/kernel/kexec.c
> +++ linux-2.6/kernel/kexec.c
> @@ -37,6 +37,7 @@
>  #include <asm/io.h>
>  #include <asm/system.h>
>  #include <asm/sections.h>
> +#include <asm/setup.h>
>  
>  /* Per cpu memory for storing cpu states in case of system crash. */
>  note_buf_t* crash_notes;
> @@ -1297,6 +1298,38 @@ int __init parse_crashkernel(char 		 *cm
>  
>  	ck_cmdline += 12; /* strlen("crashkernel=") */
>  
> +#ifdef CONFIG_KEXEC_AUTO_RESERVE
> +	if (strncmp(ck_cmdline, "auto", 4) = 0) {
> +		unsigned long long size;
> +		char tmp[32];
> +
> +		size = arch_default_crash_size(system_ram);
> +		if (size != 0) {
> +			*crash_size = size;
> +			*crash_base = arch_default_crash_base();
> +			size = scnprintf(tmp, sizeof(tmp), "%luM@%luM",
> +					(unsigned long)(*crash_size)>>20,
> +					(unsigned long)(*crash_base)>>20);
> +			/* size can't be <= 4. */
> +			if (likely((size - 4 + strlen(cmdline))
> +					< COMMAND_LINE_SIZE - 1)) {
> +				memmove(ck_cmdline + size, ck_cmdline + 4,
> +					strlen(cmdline) - (ck_cmdline + 4 - cmdline) + 1);
> +				memcpy(ck_cmdline, tmp, size);
> +			}
> +			return 0;
> +		} else {
> +			/*
> +			 * We can't reserve memory auotmatcally,
> +			 * remove "crashkernel=" from cmdline.
> +			 */
> +			ck_cmdline += 4; /* strlen("auto") */
> +			memmove(ck_cmdline - 16, ck_cmdline,
> +				strlen(cmdline) - (ck_cmdline - cmdline) + 1);
> +			return -ENOMEM;
> +		}
> +	}
> +#endif
>  	/*
>  	 * if the commandline contains a ':', then that's the extended
>  	 * syntax -- if not, it must be the classic syntax
> Index: linux-2.6/arch/x86/include/asm/kexec.h
> =================================> --- linux-2.6.orig/arch/x86/include/asm/kexec.h
> +++ linux-2.6/arch/x86/include/asm/kexec.h
> @@ -61,6 +61,29 @@
>  # define KEXEC_ARCH KEXEC_ARCH_X86_64
>  #endif
>  
> +#ifdef CONFIG_KEXEC_AUTO_RESERVE
> +#ifndef KEXEC_AUTO_RESERVED_SIZE
> +#define KEXEC_AUTO_RESERVED_SIZE 1ULL<<27 /* 128M */
> +#endif
> +#ifndef KEXEC_AUTO_THRESHOLD
> +#define KEXEC_AUTO_THRESHOLD 1ULL<<32 /* 4G */
> +#endif
> +static inline
> +unsigned long long arch_default_crash_size(unsigned long long total_size)
> +{
> +	if (total_size < KEXEC_AUTO_THRESHOLD)
> +		return 0;
> +	else
> +		return KEXEC_AUTO_RESERVED_SIZE;
> +}
> +static inline
> +unsigned long long arch_default_crash_base(void)
> +{
> +	/* On x86, 0 means find the base address automatically. */
> +	return 0;
> +}
> +#endif
> +
>  /*
>   * CPU does not save ss and sp on stack if execution is already
>   * running in kernel mode at the time of NMI occurrence. This code


What about all the other arches that support kexec?  ia64/ppc[64]/s390/etc?
Don't they need an implementation of arch_default_crash_size?  Or perhaps better
still you should put this definition in asm-generic, so that it can be
overridden per-arch if need be, but you always have something to fall back on.

Neil

