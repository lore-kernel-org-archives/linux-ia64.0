From: Simon Horman <horms@verge.net.au>
Date: Tue, 24 Apr 2007 01:49:58 +0000
Subject: Re: [PATCH] kexec/kdump: Use generic elf code on ia64
Message-Id: <20070424014955.GA14353@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070416074103.GA27981@verge.net.au>
In-Reply-To: <20070416074103.GA27981@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 20, 2007 at 01:15:34AM +0800, Zou, Nanhai wrote:
> 
> > -----Original Message-----
> > From: Simon Horman [mailto:horms@verge.net.au]
> > Sent: 2007年4月16日 16:21
> > To: fastboot@lists.osdl.org; linux-ia64@vger.kernel.org
> > Cc: Vivek Goyal; Luck, Tony; Zou, Nanhai
> > Subject: Re: [PATCH] kexec/kdump: Use generic elf code on ia64

[snip]

> > -crash_save_this_cpu(void)
> > +ia64_kexec_elf_core_copy_regs(elf_gregset_t *elfregs, struct pt_regs *regs)
> >  {
> > -	void *buf;
> >  	unsigned long cfm, sof, sol;
> > -
> > -	int cpu = smp_processor_id();
> > -	struct elf_prstatus *prstatus = &per_cpu(elf_prstatus, cpu);
> > -
> > -	elf_greg_t *dst = (elf_greg_t *)&(prstatus->pr_reg);
> > -	memset(prstatus, 0, sizeof(*prstatus));
> > -	prstatus->pr_pid = current->pid;
> > +	elf_greg_t *dst = (elf_greg_t *)elfregs;
> 
> There was a concern about struct elf_prstatus is so big on IA64 that it better not to put it on stack, consider crash happen with a deep stack..., So I put the structure into percpu data.
> 
> With this patch, it fallbacks to stack.

Thanks, I was wondering why was per_cpu rather than on the stack.
I'll rework things a bit so per_cpu data is used once again.

[snip]

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

