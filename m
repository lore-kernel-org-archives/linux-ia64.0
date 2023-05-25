From: Nadav Amit <nadav.amit@gmail.com>
Date: Thu, 25 May 2023 21:00:39 +0000
Subject: [PATCH v2 2/3] compiler: inline does not imply notrace
Message-Id: <20230525210040.3637-3-namit@vmware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230525210040.3637-1-namit@vmware.com>
In-Reply-To: <20230525210040.3637-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>

From: Nadav Amit <namit@vmware.com>

Functions that are marked as "inline" are currently also not tracable.
This limits tracing functionality for many functions for no reason.
Apparently, this has been done for two reasons.

First, as described in commit 5963e317b1e9d2a ("ftrace/x86: Do not
change stacks in DEBUG when calling lockdep"), it was intended to
prevent some functions that cannot be traced from being traced as these
functions were marked as inline (among others).

Yet, this change has been done a decade ago, and according to Steven
Rostedt, ftrace should have improved and hopefully resolved nested
tracing issues by now. Arguably, if functions that should be traced -
for instance since they are used during tracing - still exist, they
should be marked as notrace explicitly.

The second reason, which Steven raised, is that attaching "notrace" to
"inline" prevented tracing differences between different configs, which
caused various problem. This consideration is not very strong, and tying
"inline" and "notrace" does not seem very beneficial. The "inline"
keyword is just a hint, and many functions are currently not tracable
due to this reason.

Disconnect "inline" from "notrace".

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/compiler_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/compiler_types.h b/include/linux/compiler_types.h
index 547ea1ff806e..bab3e25bbe3f 100644
--- a/include/linux/compiler_types.h
+++ b/include/linux/compiler_types.h
@@ -184,7 +184,7 @@ struct ftrace_likely_data {
  * of extern inline functions at link time.
  * A lot of inline functions can cause havoc with function tracing.
  */
-#define inline inline __gnu_inline __inline_maybe_unused notrace
+#define inline inline __gnu_inline __inline_maybe_unused
 
 /*
  * gcc provides both __inline__ and __inline as alternate spellings of
-- 
2.25.1
