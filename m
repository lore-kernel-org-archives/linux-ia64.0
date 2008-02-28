From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 28 Feb 2008 20:45:22 +0000
Subject: Re: [PATCH] core dump: user_regset writeback
Message-Id: <20080228124522.3ae08f19.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080227200638.15D092700FD@magilla.localdomain>
In-Reply-To: <20080227200638.15D092700FD@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: torvalds@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, shaohua.li@intel.com, linux-ia64@vger.kernel.org

On Wed, 27 Feb 2008 12:06:38 -0800 (PST)
Roland McGrath <roland@redhat.com> wrote:

> 
> This makes the user_regset-based core dump code call user_regset
> writeback hooks when available.  This is necessary groundwork to
> allow IA64 to set CORE_DUMP_USE_REGSET.
> 
> CC: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Roland McGrath <roland@redhat.com>
> ---
>  fs/binfmt_elf.c |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 41a958a..eb7cca3 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1424,6 +1424,18 @@ struct elf_note_info {
>  	int thread_notes;
>  };
>  
> +/*
> + * When a regset has a writeback hook, we call it on each thread before
> + * dumping user memory.  On register window machines, this makes sure the
> + * user memory backing the register data is up to date before we read it.
> + */
> +static void do_thread_regset_writeback(struct task_struct *task,
> +				       const struct user_regset *regset)
> +{
> +	if (regset->writeback)
> +		regset->writeback(task, regset, 1);
> +}
> +
>  static int fill_thread_core_info(struct elf_thread_core_info *t,
>  				 const struct user_regset_view *view,
>  				 long signr, size_t *total)
> @@ -1445,6 +1457,8 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
>  		  sizeof(t->prstatus), &t->prstatus);
>  	*total += notesize(&t->notes[0]);
>  
> +	do_thread_regset_writeback(t->task, &view->regsets[0]);
> +
>  	/*
>  	 * Each other regset might generate a note too.  For each regset
>  	 * that has no core_note_type or is inactive, we leave t->notes[i]
> @@ -1452,6 +1466,7 @@ static int fill_thread_core_info(struct elf_thread_core_info *t,
>  	 */
>  	for (i = 1; i < view->n; ++i) {
>  		const struct user_regset *regset = &view->regsets[i];
> +		do_thread_regset_writeback(t->task, regset);
>  		if (regset->core_note_type &&
>  		    (!regset->active || regset->active(t->task, regset))) {
>  			int ret;

Is there a need for this in 2.6.25?
