From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Sat, 10 Jul 2021 14:55:19 +0000
Subject: [PATCH -tip 0/6] kprobes: treewide: Clean up kprobe code
Message-Id: <162592891873.1158485.768824457210707916.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: X86 ML <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

Hi Ingo,

Here is a series of patches to cleanup the kprobes code. I tried to fix
error message issues, comments, checkpatch.pl issues and so on. Some
of those are what you suggested and pointed in the x86 stacktrace series.

 https://lore.kernel.org/bpf/YOK39GTuueIDeaJL@gmail.com/

I decided to split this seires from the x86 stacktrace fix series because
there still be some on going discussions on that thread. The stacktrace
fix series will be rebased on this series (and I've almost done, except
for some discussion items).

Since this is a cleanup series, this does not change any functionality
(of course some error messages, warnings, lock assertions are chaneged)
but the coding styles are improved. I will continue this cleanup activities
for each architecture port, and rethink the internal coding design and
interfaces too.

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
 11 files changed, 226 insertions(+), 217 deletions(-)

--
Masami Hiramatsu (Linaro) <mhiramat@kernel.org>
