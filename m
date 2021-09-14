From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:41:23 +0000
Subject: [PATCH -tip v11 18/27] objtool: Ignore unwind hints for ignored functions
Message-Id: <163163048317.489837.10988954983369863209.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

From: Josh Poimboeuf <jpoimboe@redhat.com>

If a function is ignored, also ignore its hints.  This is useful for the
case where the function ignore is conditional on frame pointers, e.g.
STACK_FRAME_NON_STANDARD_FP().

Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 tools/objtool/check.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index e5947fbb9e7a..67cbdcfcabae 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -2909,7 +2909,7 @@ static int validate_unwind_hints(struct objtool_file *file, struct section *sec)
 	}
 
 	while (&insn->list != &file->insn_list && (!sec || insn->sec = sec)) {
-		if (insn->hint && !insn->visited) {
+		if (insn->hint && !insn->visited && !insn->ignore) {
 			ret = validate_branch(file, insn->func, insn, state);
 			if (ret && backtrace)
 				BT_FUNC("<== (hint)", insn);
