From: Greg Ungerer <gerg@linux-m68k.org>
Date: Tue, 12 May 2020 14:46:55 +0000
Subject: Re: [PATCH 29/31] binfmt_flat: use flush_icache_user_range
Message-Id: <484af2c0-2450-b40a-8322-e691495c45aa@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-1-hch@lst.de>
 <20200510075510.987823-30-hch@lst.de>
In-Reply-To: <20200510075510.987823-30-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Roman Zippel <zippel@linux-m68k.org>
Cc: Jessica Yu <jeyu@kernel.org>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org

Hi Christoph,

On 10/5/20 5:55 pm, Christoph Hellwig wrote:
> load_flat_file works on user addresses.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Greg Ungerer <gerg@linux-m68k.org>

Regards
Greg



> ---
>   fs/binfmt_flat.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/binfmt_flat.c b/fs/binfmt_flat.c
> index 831a2b25ba79f..6f0aca5379da2 100644
> --- a/fs/binfmt_flat.c
> +++ b/fs/binfmt_flat.c
> @@ -854,7 +854,7 @@ static int load_flat_file(struct linux_binprm *bprm,
>   #endif /* CONFIG_BINFMT_FLAT_OLD */
>   	}
>   
> -	flush_icache_range(start_code, end_code);
> +	flush_icache_user_range(start_code, end_code);
>   
>   	/* zero the BSS,  BRK and stack areas */
>   	if (clear_user((void __user *)(datapos + data_len), bss_len +
> 
