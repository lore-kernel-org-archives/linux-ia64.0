From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:19 +0000
Subject: [PATCH 9/9] ftrace, trivial: fix typo "resgister" -> "register"
Message-Id: <20090113061148.807298761@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Uwe Kleine-K?nig <ukleinek@strlen.de>, trivial@kernel.org, Steven Rostedt <srostedt@redhat.com>

From: Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>

Signed-off-by: Uwe Kleine-K?nig <ukleinek@strlen.de>
Cc: trivial@kernel.org
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 kernel/trace/ftrace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 9f53610..8c1c9c0 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -1894,7 +1894,7 @@ int register_ftrace_function(struct ftrace_ops *ops)
 }
 
 /**
- * unregister_ftrace_function - unresgister a function for profiling.
+ * unregister_ftrace_function - unregister a function for profiling.
  * @ops - ops structure that holds the function to unregister
  *
  * Unregister a function that was added to be called by ftrace profiling.
-- 
1.5.6.5

-- 
