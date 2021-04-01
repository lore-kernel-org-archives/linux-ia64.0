From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 01 Apr 2021 00:49:08 +0000
Subject: Re: [PATCH] ia64: fix user_stack_pointer() for ptrace()
Message-Id: <20210331174908.4655f2a41a7b1bbec36fae47@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210331084447.2561532-1-slyfox@gentoo.org>
In-Reply-To: <20210331084447.2561532-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org, "Dmitry V . Levin" <ldv@altlinux.org>

On Wed, 31 Mar 2021 09:44:47 +0100 Sergei Trofimovich <slyfox@gentoo.org> wrote:

> ia64 has two stacks:
> - memory stack (or stack), pointed at by by r12
> - register backing store (register stack), pointed at
>   ar.bsp/ar.bspstore with complications around dirty
>   register frame on CPU.
> 
> In https://bugs.gentoo.org/769614 Dmitry noticed that
> PTRACE_GET_SYSCALL_INFO returns register stack instead
> memory stack.
> 
> The bug comes from the fact that user_stack_pointer() and
> current_user_stack_pointer() don't return the same register:
> 
>   ulong user_stack_pointer(struct pt_regs *regs) { return regs->ar_bspstore; }
>   #define current_user_stack_pointer() (current_pt_regs()->r12)
> 
> The change gets both back in sync.
> 
> I think ptrace(PTRACE_GET_SYSCALL_INFO) is the only affected user
> by this bug on ia64.
> 
> The change fixes 'rt_sigreturn.gen.test' strace test where
> it was observed initially.
> 

I assume a cc:stable is justified here?

The bug seems to have been there for 10+ years, so there isn't a lot of
point in looking for the Fixes: reference.
