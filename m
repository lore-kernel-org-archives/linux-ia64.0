From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Date: Thu, 08 Sep 2022 14:03:11 +0000
Subject: [PATCH v3 0/2] Introduce CABA helper process tree
Message-Id: <20220908140313.313020-1-ptikhomirov@virtuozzo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Biederman <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Andrei Vagin <avagin@google.com>, linux-kernel@vger.kernel.org
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Valentin Schneider <vschneid@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, kernel@openvz.org

CABA = Closest Alive Born Ancestor

In Linux process tree we reparent children of a dying process to the
reaper, thus loosing information in which subtree the child was
originally born. This information can be useful to CRIU to restore
process trees right.

The idea of CABA tree is to keep reference to the closest "born"
ancestor in the process tree. In simple case if our "born" parent dies
(completely unhashed) CABA would then point to its "born" parent - our
"born" grand-parent. So CABA is always referencing closest "born"
(grand-)*parent in available processes.

Please see "Add CABA tree to task_struct" for deeper explanation, and
"tests: Add CABA selftest" for a small test and an actual example for
which we might need CABA.

Probably the original problem of restoring process tree with complex
sessions can be resolved by allowing sessions copying, like we do for
process group, but I'm not sure if that would be too secure to do it,
and if there would not be another similar resource in future. So I
prefere CABA.

Also we can use CABA not only for CRIU for restoring processes, but in
normal life when processes detach CABA will help to understand from
which place in process tree they were originally started from sshd/crond
or something else.

Hope my idea is not completely insane =)

I plan to have a talk on LPC 2022 about it https://lpc.events/event/16/contributions/1241/

CC: Eric Biederman <ebiederm@xmission.com>
CC: Kees Cook <keescook@chromium.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Ingo Molnar <mingo@redhat.com>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Juri Lelli <juri.lelli@redhat.com>
CC: Vincent Guittot <vincent.guittot@linaro.org>
CC: Dietmar Eggemann <dietmar.eggemann@arm.com>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Ben Segall <bsegall@google.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Daniel Bristot de Oliveira <bristot@redhat.com>
CC: Valentin Schneider <vschneid@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
CC: linux-fsdevel@vger.kernel.org
CC: kernel@openvz.org

Pavel Tikhomirov (2):
  Add CABA tree to task_struct
  tests: Add CABA selftest

 arch/ia64/kernel/mca.c                   |   3 +
 fs/exec.c                                |   1 +
 fs/proc/array.c                          |  20 +
 include/linux/sched.h                    |   7 +
 init/init_task.c                         |   3 +
 kernel/exit.c                            |  21 +
 kernel/fork.c                            |   4 +
 tools/testing/selftests/Makefile         |   1 +
 tools/testing/selftests/caba/.gitignore  |   1 +
 tools/testing/selftests/caba/Makefile    |   7 +
 tools/testing/selftests/caba/caba_test.c | 509 +++++++++++++++++++++++
 tools/testing/selftests/caba/config      |   1 +
 12 files changed, 578 insertions(+)
 create mode 100644 tools/testing/selftests/caba/.gitignore
 create mode 100644 tools/testing/selftests/caba/Makefile
 create mode 100644 tools/testing/selftests/caba/caba_test.c
 create mode 100644 tools/testing/selftests/caba/config

-- 
2.37.1
