From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:10 +0000
Subject: [PATCH 0/9] ftrace: updates for tip
Message-Id: <20090113061110.856268617@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de


The following patches are in:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

    branch: tip/devel


Frederic Weisbecker (2):
      tracing/ftrace: separate events tracing and stats tracing engine
      tracing: add a new workqueue tracer

Shaohua Li (6):
      ftrace, ia64: make recordmcount destinct module compile
      ftrace, ia64: explictly ignore a file in recordmcount.pl
      ftrace, ia64: Add macro for ftrace_caller
      ftrace, ia64: Add recordmcount for ia64
      ftrace, ia64: IA64 static ftrace support
      ftrace, ia64: IA64 dynamic ftrace support

Uwe Kleine-K?nig (1):
      ftrace, trivial: fix typo "resgister" -> "register"

----
 arch/ia64/Kconfig              |    3 +
 arch/ia64/include/asm/ftrace.h |   28 ++++
 arch/ia64/kernel/Makefile      |    5 +
 arch/ia64/kernel/entry.S       |  100 ++++++++++++++
 arch/ia64/kernel/ftrace.c      |  206 ++++++++++++++++++++++++++++
 arch/ia64/kernel/ia64_ksyms.c  |    6 +
 include/linux/ftrace.h         |    4 +
 include/trace/workqueue.h      |   25 ++++
 kernel/trace/Kconfig           |   11 ++
 kernel/trace/Makefile          |    1 +
 kernel/trace/ftrace.c          |   14 +--
 kernel/trace/trace.c           |    2 -
 kernel/trace/trace.h           |   20 ---
 kernel/trace/trace_branch.c    |  108 +++++++++-------
 kernel/trace/trace_stat.c      |  191 +++++++++++---------------
 kernel/trace/trace_stat.h      |   31 +++++
 kernel/trace/trace_workqueue.c |  287 ++++++++++++++++++++++++++++++++++++++++
 kernel/workqueue.c             |   16 ++-
 scripts/Makefile.build         |   13 +-
 scripts/recordmcount.pl        |   18 ++-
 20 files changed, 888 insertions(+), 201 deletions(-)
-- 
