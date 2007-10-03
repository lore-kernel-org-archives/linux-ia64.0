From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 03 Oct 2007 06:11:38 +0000
Subject: Re: [patch 2/2] ia64 perfmon: Remove exit_pfm_fs()
Message-Id: <20071003061138.GA25462@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200710022039.l92Kdk8O021184@imap1.linux-foundation.org>
In-Reply-To: <200710022039.l92Kdk8O021184@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Satyam,

Thanks for cleaning this up. I have also removed it from the newer
perfmon2 code base.

On Tue, Oct 02, 2007 at 01:39:46PM -0700, akpm@linux-foundation.org wrote:
> From: "Satyam Sharma" <satyam.sharma@gmail.com>
> 
> Because it is dead code and not referenced by anybody else (that file cannot
> be built modular).
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Cc: Stephane Eranian <eranian@hpl.hp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  arch/ia64/kernel/perfmon.c |    7 -------
>  1 file changed, 7 deletions(-)
> 
> diff -puN arch/ia64/kernel/perfmon.c~ia64-perfmon-remove-exit_pfm_fs arch/ia64/kernel/perfmon.c
> --- a/arch/ia64/kernel/perfmon.c~ia64-perfmon-remove-exit_pfm_fs
> +++ a/arch/ia64/kernel/perfmon.c
> @@ -1538,13 +1538,6 @@ init_pfm_fs(void)
>  	return err;
>  }
>  
> -static void __exit
> -exit_pfm_fs(void)
> -{
> -	unregister_filesystem(&pfm_fs_type);
> -	mntput(pfmfs_mnt);
> -}
> -
>  static ssize_t
>  pfm_read(struct file *filp, char __user *buf, size_t size, loff_t *ppos)
>  {
> _

-- 

-Stephane
