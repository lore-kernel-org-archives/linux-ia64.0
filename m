From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 05 Jul 2021 07:48:09 +0000
Subject: Re: [PATCH -tip v8 02/13] kprobes: treewide: Replace arch_deref_entry_point() with dereference_symbo
Message-Id: <YOK5OV0zdjvrsqju@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
 <162399994018.506599.10332627573727646767.stgit@devnote2>
In-Reply-To: <162399994018.506599.10332627573727646767.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>


* Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Replace arch_deref_entry_point() with dereference_symbol_descriptor()
> because those are doing same thing.
> 
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> Tested-by: Andrii Nakryik <andrii@kernel.org>

A better changelog:

  ~15 years ago kprobes grew the 'arch_deref_entry_point()' __weak function:

    3d7e33825d87: ("jprobes: make jprobes a little safer for users")

  But this is just open-coded dereference_symbol_descriptor() in essence, and
  its obscure nature was causing bugs.

  Just use the real thing.

Thanks,

	Ingo
