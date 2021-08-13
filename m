From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Fri, 13 Aug 2021 15:26:14 +0000
Subject: Re: [PATCH -tip v3 0/6] kprobes: treewide: Clean up kprobe code
Message-Id: <20210814002614.1e4711003e9013e0b60aa789@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <162748615977.59465.13262421617578791515.stgit@devnote2>
In-Reply-To: <162748615977.59465.13262421617578791515.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: X86 ML <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Joe Perches <joe@perches.com>

Hi Ingo,

Could you pick this series if no problem?
These patches do not change any functionalities. (of course some of them
changes function APIs, like the type of return value and arguments)

Thank you,

On Thu, 29 Jul 2021 00:29:20 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> Hi,
> 
> Here is the 3rd series of patches to cleanup the kprobes code. Previous
> version is here.
> 
>  https://lore.kernel.org/bpf/162598881438.1222130.11530594038964049135.stgit@devnote2/
> 
> This version is rebased on the latest tip/master and Punit's cleanup series;
> 
>  https://lore.kernel.org/linux-csky/20210727133426.2919710-1-punitagrawal@gmail.com/
> 
> Just fixed some conflicts, basically no change.
> 
> I pushed his series and this series as the 'kprobes/cleanup' branch on my tree.
> So you can pull the series (and Punit's series too) from the branch below.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/mhiramat/linux.git kprobes/cleanup 
> 
> Thank you,
> 
> ---
> 
> Masami Hiramatsu (6):
>       kprobes: treewide: Cleanup the error messages for kprobes
>       kprobes: Fix coding style issues
>       kprobes: Use IS_ENABLED() instead of kprobes_built_in()
>       kprobes: Add assertions for required lock
>       kprobes: treewide: Use 'kprobe_opcode_t *' for the code address in get_optimized_kprobe()
>       kprobes: Use bool type for functions which returns boolean value
> 
> 
>  arch/arm/probes/kprobes/core.c     |    4 
>  arch/arm/probes/kprobes/opt-arm.c  |    7 -
>  arch/arm64/kernel/probes/kprobes.c |    5 -
>  arch/csky/kernel/probes/kprobes.c  |   10 +
>  arch/mips/kernel/kprobes.c         |   11 +
>  arch/powerpc/kernel/optprobes.c    |    6 -
>  arch/riscv/kernel/probes/kprobes.c |   11 +
>  arch/s390/kernel/kprobes.c         |    4 
>  arch/x86/kernel/kprobes/opt.c      |    6 -
>  include/linux/kprobes.h            |   64 +++----
>  kernel/kprobes.c                   |  313 +++++++++++++++++++-----------------
>  kernel/trace/trace_kprobe.c        |    2 
>  12 files changed, 226 insertions(+), 217 deletions(-)
> 
> --
> Masami Hiramatsu (Linaro) <mhiramat@kernel.org>


-- 
Masami Hiramatsu <mhiramat@kernel.org>
