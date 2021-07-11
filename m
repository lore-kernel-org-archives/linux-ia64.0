From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sun, 11 Jul 2021 07:33:34 +0000
Subject: [PATCH -tip v2 0/6] kprobes: treewide: Clean up kprobe code
Message-Id: <162598881438.1222130.11530594038964049135.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: X86 ML <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Joe Perches <joe@perches.com>

Hi,

Here is the 2nd series of patches to cleanup the kprobes code. Previous
version is here.

 https://lore.kernel.org/bpf/162592891873.1158485.768824457210707916.stgit@devnote2/

This version is just add a cleanup of trace_kprobes to the [6/6], thanks
Joe to find it out!


Thank you,

---

Masami Hiramatsu (6):
      kprobes: treewide: Cleanup the error messages for kprobes
      kprobes: Fix coding style issues
      kprobes: Use IS_ENABLED() instead of kprobes_built_in()
      kprobes: Add assertions for required lock
      kprobes: treewide: Use 'kprobe_opcode_t *' for the code address in get_optimized_kprobe()
      kprobes: Use bool type for functions which returns boolean value


 arch/arm/probes/kprobes/core.c     |    4 
 arch/arm/probes/kprobes/opt-arm.c  |    7 -
 arch/arm64/kernel/probes/kprobes.c |    5 -
 arch/csky/kernel/probes/kprobes.c  |   10 +
 arch/mips/kernel/kprobes.c         |   11 +
 arch/powerpc/kernel/optprobes.c    |    6 -
 arch/riscv/kernel/probes/kprobes.c |   11 +
 arch/s390/kernel/kprobes.c         |    4 
 arch/x86/kernel/kprobes/opt.c      |    6 -
 include/linux/kprobes.h            |   64 +++----
 kernel/kprobes.c                   |  315 +++++++++++++++++++-----------------
 kernel/trace/trace_kprobe.c        |    2 
 12 files changed, 227 insertions(+), 218 deletions(-)

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
