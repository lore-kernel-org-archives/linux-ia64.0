From: Dave Hansen <dave.hansen@intel.com>
Date: Tue, 16 Mar 2021 21:16:35 +0000
Subject: Re: [PATCH] mm: Move mem_init_print_info() into mm_init()
Message-Id: <009553ee-8d7b-0b60-8457-f8ac66e27fb4@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210316142637.92193-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20210316142637.92193-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Richard Henderson <rth@twiddle.net>, Guo Ren <guoren@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Huacai Chen <chenhuacai@kernel.org>, Jonas Bonn <jonas@southpole.se>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, "David S. Miller" <davem@davemloft.net>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org

On 3/16/21 7:26 AM, Kefeng Wang wrote:
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 5430c81eefc9..aa8387aab9c1 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1350,8 +1350,6 @@ void __init mem_init(void)
>  		kclist_add(&kcore_vsyscall, (void *)VSYSCALL_ADDR, PAGE_SIZE, KCORE_USER);
>  
>  	preallocate_vmalloc_pages();
> -
> -	mem_init_print_info(NULL);
>  }

Ignoring any issues with the printk...

Looks harmless enough on x86.  The 32-bit code has some cruft in
mem_init() after mem_init_print_info(), so this patch will change the
location of the mem_init_print_info(), but I think it's actually for the
better, since it will be pushed later in boot.  As long as the x86
pieces stay the same:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
