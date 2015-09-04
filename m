From: Chen Gang <gchen_5i5j@21cn.com>
Date: Fri, 04 Sep 2015 03:43:15 +0000
Subject: Re: [PATCH] arch: ia64: kernel: perfmon: Check return value of insert_vm_struct()
Message-Id: <55E91353.8010005@21cn.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <COL130-W46DBE61538E64374C967CB9630@phx.gbl>
In-Reply-To: <COL130-W46DBE61538E64374C967CB9630@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: kernel mailing list <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tony.luck@intel.com, Fenghua Yu <fenghua.yu@intel.com>

Hello Maintainers:

Please help check this patch when you have time.

Thanks.

On 8/24/15 01:18, Chen Gang wrote:
> In pfm_smpl_buffer_alloc, insert_vm_struct may also return -ENOMEM, so
> need check it too.
> 
> And insert_vm_struct needn't consider about pfm_remap_buffer in failure
> process ("goto error" is enough):
> 
>  - pfm_remap_buffer doen't consider about remap_pfn_range.
> 
>  - It is about the relationship between vma and smpl_buf.
> 
>  - SO if both vma and smpl_buf are released ("goto error"), all things
>    are OK.
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  arch/ia64/kernel/perfmon.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
> index 60e02f7..ae77946 100644
> --- a/arch/ia64/kernel/perfmon.c
> +++ b/arch/ia64/kernel/perfmon.c
> @@ -2330,7 +2330,11 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
>  	 * now insert the vma in the vm list for the process, must be
>  	 * done with mmap lock held
>  	 */
> -	insert_vm_struct(mm, vma);
> +	if (insert_vm_struct(mm, vma)) {
> +		DPRINT(("Can't insert vm structure.\n"));
> +		up_write(&task->mm->mmap_sem);
> +		goto error;
> +	}
>  
>  	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
>  							vma_pages(vma));
> -- 
> 
>  		 	   		  
> 

-- 
Chen Gang (陈刚)

Open, share, and attitude like air, water, and life which God blessed
