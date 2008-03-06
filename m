From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 06 Mar 2008 08:17:09 +0000
Subject: Re: [patch 1/3] ia64: fix ptrace inside a namespace
Message-Id: <1204791429.16716.1.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200803042314.m24NEwT5002321@imap1.linux-foundation.org>
In-Reply-To: <200803042314.m24NEwT5002321@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2008-03-04 at 15:14 -0800, akpm@linux-foundation.org wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> 
> The ia64 has its own sys_ptrace implementation and it was overlooked when the
> pid namespaces patches were sent.
> 
> Use find_task_by_vpid() in it.

And there we are. If we don't push the ptrace() changes into mainline
soon, mainline will drift away from us. :(

Cheers,
Petr Tesarik

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  arch/ia64/kernel/ptrace.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN arch/ia64/kernel/ptrace.c~ia64-fix-ptrace-inside-a-namespace arch/ia64/kernel/ptrace.c
> --- a/arch/ia64/kernel/ptrace.c~ia64-fix-ptrace-inside-a-namespace
> +++ a/arch/ia64/kernel/ptrace.c
> @@ -1561,7 +1561,7 @@ sys_ptrace (long request, pid_t pid, uns
>  	ret = -ESRCH;
>  	read_lock(&tasklist_lock);
>  	{
> -		child = find_task_by_pid(pid);
> +		child = find_task_by_vpid(pid);
>  		if (child) {
>  			if (peek_or_poke)
>  				child = find_thread_for_addr(child, addr);
> _
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
