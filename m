From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 07:46:33 +0000
Subject: Re: [PATCH -tip v8 01/13] ia64: kprobes: Fix to pass correct trampoline address to the handler
Message-Id: <YOK42eM70kb9fd6r@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162399993125.506599.11062077324255866677.stgit@devnote2>
In-Reply-To: <162399993125.506599.11062077324255866677.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Commit e792ff804f49 ("ia64: kprobes: Use generic kretprobe trampoline handler")
> missed to pass the wrong trampoline address (it passes the descriptor address
> instead of function entry address).
> This fixes it to pass correct trampoline address to __kretprobe_trampoline_handler().
> This also changes to use correct symbol dereference function to get the
> function address from the kretprobe_trampoline.
> 
> Fixes: e792ff804f49 ("ia64: kprobes: Use generic kretprobe trampoline handler")
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>

A better changelog:

  The following commit:

     Commit e792ff804f49 ("ia64: kprobes: Use generic kretprobe trampoline handler")

  Passed the wrong trampoline address to __kretprobe_trampoline_handler(): it
  passes the descriptor address instead of function entry address.

  Pass the right parameter.

  Also use correct symbol dereference function to get the function address
  from 'kretprobe_trampoline' - an IA64 special.

(Although I realize that much of this goes away just a couple of patches 
later.)

Thanks,

	Ingo
