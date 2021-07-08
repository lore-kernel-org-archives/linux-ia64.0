From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Thu, 08 Jul 2021 04:08:56 +0000
Subject: Re: [PATCH -tip v8 02/13] kprobes: treewide: Replace arch_deref_entry_point() with dereference_symbo
Message-Id: <20210708130856.ccb7cfb4f92e5896d597906a@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162399992186.506599.8457763707951687195.stgit@devnote2>
        <162399994018.506599.10332627573727646767.stgit@devnote2>
        <CAEf4BzY1D7NsrBwt3nLFRbaESb7b5pR9arLhrg8OmOAfxi+kaw@mail.gmail.com>
In-Reply-To: <CAEf4BzY1D7NsrBwt3nLFRbaESb7b5pR9arLhrg8OmOAfxi+kaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrii Nakryiko <andrii.nakryiko@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, open list <linux-kernel@vger.kernel.org>, bpf <bpf@vger.kernel.org>, Jakub Kicinski <kuba@kernel.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, Kernel Team <kernel-team@fb.com>, Yonghong Song <yhs@fb.com>, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>

On Wed, 7 Jul 2021 11:28:10 -0700
Andrii Nakryiko <andrii.nakryiko@gmail.com> wrote:

> On Fri, Jun 18, 2021 at 12:05 AM Masami Hiramatsu <mhiramat@kernel.org> wrote:
> >
> > Replace arch_deref_entry_point() with dereference_symbol_descriptor()
> > because those are doing same thing.
> >
> > Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
> > Tested-by: Andrii Nakryik <andrii@kernel.org>
> 
> Hi Masami,
> 
> If you are going to post v9 anyway, can you please fix up my name, it
> should be "Andrii Nakryiko", thanks!

Oops, sorry. OK, I'll fix it.

Thank you,

> 
> > ---
> >  Changes in v6:
> >   - Use dereference_symbol_descriptor() so that it can handle address in
> >     modules correctly.
> > ---
> >  arch/ia64/kernel/kprobes.c    |    5 -----
> >  arch/powerpc/kernel/kprobes.c |   11 -----------
> >  include/linux/kprobes.h       |    1 -
> >  kernel/kprobes.c              |    7 +------
> >  lib/error-inject.c            |    3 ++-
> >  5 files changed, 3 insertions(+), 24 deletions(-)
> >
> 
> [...]


-- 
Masami Hiramatsu <mhiramat@kernel.org>
