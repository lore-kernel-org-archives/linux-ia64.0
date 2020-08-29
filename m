From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 29 Aug 2020 18:20:57 +0000
Subject: Re: [PATCH 2/3] ia64: remove unneeded header includes from <asm/mca.h>
Message-Id: <e3dabd8d-352f-7471-3e4a-4d24d74e715b@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
 <20200829051524.706585-3-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-3-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: linux-kbuild@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, afzal mohammed <afzal.mohd.ma@gmail.com>, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/28/20 10:15 PM, Masahiro Yamada wrote:
> <asm/mca.h> includes too many unneeded headers.
> 
> This commit cuts off a lot of header includes.
> 
> What we need to include are:
> 
>  - <linux/percpu.h> for DECLARE_PER_CPU(u64, ia64_mca_pal_base)
>  - <linux/threads.h> for NR_CPUS
>  - <linux/types.h> for u8, u64, size_t, etc.
>  - <asm/ptrace.h> for KERNEL_STACK_SIZE
> 
> The other header includes are actually unneeded.
> 
> <asm/mca.h> previously included 436 headers, and now it includes
> only 138. I confirmed <asm/mca.h> is still self-contained.

Nice!

> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

> ---
> 
>  arch/ia64/include/asm/mca.h | 9 +++------
>  arch/ia64/kernel/efi.c      | 1 +
>  arch/ia64/kernel/mca.c      | 1 +
>  3 files changed, 5 insertions(+), 6 deletions(-)
> 


thanks.
-- 
~Randy
