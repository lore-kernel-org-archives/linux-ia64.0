From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 07:49:34 +0000
Subject: Re: [PATCH -tip v8 03/13] kprobes: treewide: Remove trampoline_address from kretprobe_trampoline_han
Message-Id: <YOK5jnkaqNCMQkJi@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162399994996.506599.17672270294950096639.stgit@devnote2>
In-Reply-To: <162399994996.506599.17672270294950096639.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Remove trampoline_address from kretprobe_trampoline_handler().
> Instead of passing the address, kretprobe_trampoline_handler()
> can use new kretprobe_trampoline_addr().
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> Tested-by: Andrii Nakryik <andrii@kernel.org>

A better changelog:

   The __kretprobe_trampoline_handler() callback, called from low level 
   arch kprobes methods, has the 'trampoline_address' parameter, which is 
   entirely superfluous as it basically just replicates:

        dereference_kernel_function_descriptor(kretprobe_trampoline)

   In fact we had bugs in arch code where it wasn't replicated correctly.

   So remove this superfluous parameter and use kretprobe_trampoline_addr() 
   instead.

Thanks,

	Ingo
