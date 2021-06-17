From: Josh Poimboeuf <jpoimboe@redhat.com>
Date: Thu, 17 Jun 2021 04:41:00 +0000
Subject: Re: [PATCH -tip v7 10/13] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <20210617044100.swsgkyio5wwdl2ic@treble>
List-Id: <linux-ia64.vger.kernel.org>
References: <162209754288.436794.3904335049560916855.stgit@devnote2>
 <162209763886.436794.6585363781863933939.stgit@devnote2>
In-Reply-To: <162209763886.436794.6585363781863933939.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, tglx@linutronix.de, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Thu, May 27, 2021 at 03:40:39PM +0900, Masami Hiramatsu wrote:
> This changes x86/kretprobe stack frame on kretprobe_trampoline
> a bit, which now push the kretprobe_trampoline as a fake return
> address at the bottom of the stack frame. With this fix, the ORC
> unwinder will see the kretprobe_trampoline as a return address.
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> Suggested-by: Josh Poimboeuf <jpoimboe@redhat.com>
> Tested-by: Andrii Nakryik <andrii@kernel.org>

Acked-by: Josh Poimboeuf <jpoimboe@redhat.com>

-- 
Josh
