From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 08:17:26 +0000
Subject: Re: [PATCH -tip v8 10/13] x86/kprobes: Push a fake return address at kretprobe_trampoline
Message-Id: <YOLAFswnvyNReMmI@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162400001661.506599.5153975410607447958.stgit@devnote2>
In-Reply-To: <162400001661.506599.5153975410607447958.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> +	/* Replace fake return address with real one. */
> +	*frame_pointer = kretprobe_trampoline_handler(regs, frame_pointer);
> +	/*
> +	 * Move flags to sp so that kretprobe_trapmoline can return
> +	 * right after popf.

What is a trapmoline?

Also, in the x86 code we capitalize register and instruction names so that 
they are more distinctive and easier to read in the flow of English text.

Thanks,

	Ingo
