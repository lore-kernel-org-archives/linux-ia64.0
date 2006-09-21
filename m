From: Vivek Goyal <vgoyal@in.ibm.com>
Date: Thu, 21 Sep 2006 20:44:35 +0000
Subject: Re: [Fastboot] [Patch] Kexec-tools: Fix physcal address value in vmcore ELF	segment header
Message-Id: <20060921204435.GA18921@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060921111550.GI18110@verge.net.au>
In-Reply-To: <20060921111550.GI18110@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 21, 2006 at 01:01:04PM +0800, Zou Nan hai wrote:
> 
> I used fixed 64M as physical offset in vmcore ELF segment header.
> This gives trouble to crash utility to analyze vmcore on platform that
> load kernel to a different address.
> 
> This patch will fix it.
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> diff -Nraup kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c kexec-tools-1.101-fix/kexec/arch/ia64/crashdump-ia64.c
> --- kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c	2006-09-20 15:29:29.000000000 +0800
> +++ kexec-tools-1.101-fix/kexec/arch/ia64/crashdump-ia64.c	2006-09-20 15:32:27.000000000 +0800
> @@ -28,7 +28,7 @@
>  #include "crashdump-ia64.h"
>  
>  int memory_ranges = 0;
> -#define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - (1UL<<26))
> +#define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - kernel_code_start)

This will work as long as virtual address for which kernel is being compiled
remains same. (I guess, 0xa000000000000000UL + 0x100000000UL). If you shift
the kernel little bit in virtual address space, this assumption will be
broken.

That's why I put a patch to read /proc/kcore and determine for which
virtual address the kernel has been built and there is no hardcoding.
(Thanks to Eric for the suggestion.)

-Vivek
