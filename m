From: Joe Perches <joe@perches.com>
Date: Sat, 10 Jul 2021 16:27:22 +0000
Subject: Re: [PATCH -tip 6/6] kprobes: Use bool type for functions which returns boolean value
Message-Id: <dd3ec20d371703c121a18e91908ab8faa76c852d.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <162592891873.1158485.768824457210707916.stgit@devnote2>
         <162592897337.1158485.13933847832718343850.stgit@devnote2>
In-Reply-To: <162592897337.1158485.13933847832718343850.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Masami Hiramatsu <mhiramat@kernel.org>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>

On Sat, 2021-07-10 at 23:56 +0900, Masami Hiramatsu wrote:
> Use the 'bool' type instead of 'int' for the functions which
> returns a boolean value, because this makes clear that those
> functions don't return any error code.
[]
> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
[]
> @@ -104,25 +104,25 @@ struct kprobe {
> =A0#define KPROBE_FLAG_FTRACE	8 /* probe is using ftrace */
> =A0
>=20
> =A0/* Has this kprobe gone ? */
> -static inline int kprobe_gone(struct kprobe *p)
> +static inline bool kprobe_gone(struct kprobe *p)
> =A0{
> =A0	return p->flags & KPROBE_FLAG_GONE;
> =A0}

This change would also allow the removal of the !! from:

kernel/trace/trace_kprobe.c:104:        return !!(kprobe_gone(&tk->rp.kp));
---
 kernel/trace/trace_kprobe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index ea6178cb5e334..c6e0345a44e94 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -101,7 +101,7 @@ static nokprobe_inline unsigned long trace_kprobe_offse=
t(struct trace_kprobe *tk
=20
 static nokprobe_inline bool trace_kprobe_has_gone(struct trace_kprobe *tk)
 {
-	return !!(kprobe_gone(&tk->rp.kp));
+	return kprobe_gone(&tk->rp.kp);
 }
=20
 static nokprobe_inline bool trace_kprobe_within_module(struct trace_kprobe=
 *tk,

