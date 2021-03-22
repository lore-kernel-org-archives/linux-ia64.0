From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Mon, 22 Mar 2021 23:56:26 +0000
Subject: Re: [PATCH -tip v4 12/12] tracing: Show kretprobe unknown indicator only for kretprobe_trampoline
Message-Id: <20210323085626.111af4e087b4f8e35fff2e8d@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <161639518354.895304.15627519393073806809.stgit@devnote2>
        <161639532235.895304.18329540036405219298.stgit@devnote2>
        <20210322111142.748e90da@gandalf.local.home>
In-Reply-To: <20210322111142.748e90da@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, Josh Poimboeuf <jpoimboe@redhat.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

Hi Steve,

On Mon, 22 Mar 2021 11:11:42 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Mon, 22 Mar 2021 15:42:02 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > ftrace shows "[unknown/kretprobe'd]" indicator all addresses in the
> > kretprobe_trampoline, but the modified address by kretprobe should
> > be only kretprobe_trampoline+0.
> > 
> > Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> 
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

Thank you for the Ack!

> 
> -- Steve
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
