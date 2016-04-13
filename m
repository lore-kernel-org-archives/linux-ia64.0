From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 13 Apr 2016 09:16:26 +0000
Subject: Re: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <20160413091625.GF14351@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
 <1460041951-22347-11-git-send-email-mhocko@kernel.org>
 <20160413090829.GB29579@gmail.com>
In-Reply-To: <20160413090829.GB29579@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On Wed 13-04-16 11:08:30, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > +ENTRY(call_rwsem_down_write_failed_killable)
> > +	save_common_regs
> > +	movq %rax,%rdi
> > +	call rwsem_down_write_failed_killable
> > +	restore_common_regs
> > +	ret
> > +ENDPROC(call_rwsem_down_write_failed_killable)
> 
> Got this objtool warning on x86-64 allyesconfig:
> 
>   arch/x86/lib/rwsem.o: warning: objtool: call_rwsem_down_write_failed_killable()+0xe: call without frame pointer save/setup

Peter has already pointed that out. This is because the 4.5 which I was
basing my work on doesn't have 3387a535ce62 ("x86/asm: Create stack
frames in rwsem functions") which shown up in 4.6-rc1. He mentioned to
add the missing FRAME_{BEGIN,END} during the merge AFAIR.

Does that sound reasonable to you or should I rebase?

-- 
Michal Hocko
SUSE Labs
