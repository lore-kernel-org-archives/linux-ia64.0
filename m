From: Don Dugger <n0ano@valinux.com>
Date: Tue, 03 Jul 2001 21:16:35 +0000
Subject: Re: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chas-

Looking back at your last message I think you are compiling your
module with the wrong flags.  My kernel uses the flag
`-mconstant-gp' which I didn't see in your flags list.  In general,
you must compile your modules with the same flags that were
used to compile the kernel.

On Tue, Jul 03, 2001 at 04:53:56PM -0400, chas williams wrote:
> >where the first element truly points to the function and the second
> >element contains the GP value for the function.
> 
> ok. i see. so i can now set the syscall table to the 'real' location
> for the afs_syscall routine.  however, i still run into trouble
> when invoking the syscall:
> 
> >>IP;  a000000000034250 <[mysyscall].text.end+11/31>   <==> >>b0;  a0000000000340e0 <[mysyscall].text.start+20/40>
> >>b6;  e000000004402f60 <demine_args+0/a0>
> >>b7;  e0000000044157b0 <ia64_switch_to+b0/120>
> Trace; e00000000441a080 <show_stack+40/c0>
> Trace; e00000000441a840 <show_regs+740/780>
> Trace; e00000000442b830 <die_if_kernel+70/140>
> Trace; e000000004443fc0 <ia64_do_page_fault+760/800>
> Trace; e000000004415d00 <ia64_leave_kernel+0/2a0>
> Trace; a000000000034250 <[mysyscall].text.end+11/31>
> Trace; a0000000000340e0 <[mysyscall].text.start+20/40>
> Trace; a0000000000340e0 <[mysyscall].text.start+20/40>
> 
> i suspect that my afs_syscall() is trying to use the 'gp' which is
> probably not setup?
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

