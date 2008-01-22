From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 22 Jan 2008 01:07:46 +0000
Subject: Re: [PATCH]Fix the order of atomic operations in
Message-Id: <1200964066.1353.0.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4790D1DE.8030700@redhat.com>
In-Reply-To: <4790D1DE.8030700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@redhat.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, ia64 <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, systemtap-ml <systemtap@sources.redhat.com>


On Sat, 2008-01-19 at 00:20 +0800, Masami Hiramatsu wrote:
> From: Masami Hiramatsu <mhiramat@redhat.com>
> 
> Fix the order of atomic operations to prevent overwriting
> prev_kprobe[0].
> To pop values from stack, we must decrement stack index right AFTER
> reading values.
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
> ---
> Details of this issue was reported to
> http://sources.redhat.com/bugzilla/show_bug.cgi?id 71
> 
>    arch/ia64/kernel/kprobes.c |    7 ++++---
>    1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: 2.6.24-rc8/arch/ia64/kernel/kprobes.c
> =================================> --- 2.6.24-rc8.orig/arch/ia64/kernel/kprobes.c  2008-01-17
> 21:14:01.000000000 -0500
> +++ 2.6.24-rc8/arch/ia64/kernel/kprobes.c       2008-01-17
> 21:14:01.000000000 -0500
> @@ -381,9 +381,10 @@
>    static void __kprobes restore_previous_kprobe(struct kprobe_ctlblk
> *kcb)
>    {
>         unsigned int i;
> -       i = atomic_sub_return(1, &kcb->prev_kprobe_index);
> -       __get_cpu_var(current_kprobe) = kcb->prev_kprobe[i].kp;
> -       kcb->kprobe_status = kcb->prev_kprobe[i].status;
> +       i = atomic_read(&kcb->prev_kprobe_index);
> +       __get_cpu_var(current_kprobe) = kcb->prev_kprobe[i-1].kp;
> +       kcb->kprobe_status = kcb->prev_kprobe[i-1].status;
> +       atomic_sub(1, &kcb->prev_kprobe_index);
>    }
> 
>    static void __kprobes set_current_kprobe(struct kprobe *p,
Acked. Thanks for the patch.

Thanks,
Shaohua

