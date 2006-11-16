From: "bibo,mao" <bibo.mao@intel.com>
Date: Thu, 16 Nov 2006 09:42:47 +0000
Subject: Re: [small patch] ia64 find thread for user rbs address
Message-Id: <455C3297.1050402@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <455C193D.9090509@intel.com>
In-Reply-To: <455C193D.9090509@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,
please discard this patch. It can not fix completely. If ptrace
caller wants to access vforked child process's user rbs, there
will be problem.

thanks
bibo,mao

bibo,mao wrote:
> hi,
>   I encountered one problem when running ptrace test case, the
> situation is this: traced process's syscall parameter needs to
> be accessed, but for sys_clone system call with clone_flag
> (CLONE_VFORK | CLONE_VM | SIGCHLD) parameter. this syscall's
> parameter accessing result is wrong.
>   The reason is that with clone_flag(CLONE_VFORK | CLONE_VM | SIGCHLD),
> cloned thread's mm point is the same, but tgid is different.
> without this patch find_thread_for_addr will return cloned thread,
> but not the thread which call sys_clone syscall.
> 
> thanks
> bibo,mao
> 
> --- 2.6.19-rc5.org/arch/ia64/kernel/ptrace.c    2006-11-16 16:23:31.000000000 +0800
> +++ 2.6.19-rc5/arch/ia64/kernel/ptrace.c        2006-11-16 16:25:07.000000000 +0800
> @@ -607,7 +607,7 @@ find_thread_for_addr (struct task_struct
>          */
>         list_for_each_safe(this, next, &current->children) {
>                 p = list_entry(this, struct task_struct, sibling);
> -               if (p->mm != mm)
> +               if (p->tgid != child->tgid)
>                         continue;
>                 if (thread_matches(p, addr)) {
>                         child = p;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
