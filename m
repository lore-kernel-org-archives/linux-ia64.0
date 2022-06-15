From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Date: Wed, 15 Jun 2022 16:08:17 +0000
Subject: [PATCH v2 0/2] Introduce CABA helper process tree
Message-Id: <20220615160819.242520-1-ptikhomirov@virtuozzo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>, Alexander Mikhalitsyn <alexander.mikhalitsyn@virtuozzo.com>, Eric Biederman <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Juri Lelli <juri.lelli@redhat.com>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Ben Segall <bsegall@google.com>, Mel Gorman <mgorman@suse.de>, Daniel Bristot de Oliveira <bristot@redhat.com>, Valentin Schneider <vschneid@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, kernel@openvz.org

Please see "Add CABA tree to task_struct" for deeper explanation, and
"tests: Add CABA selftest" for a small test and an actual case for which
we might need CABA.

Probably the original problem of restoring process tree with complex
sessions can be resolved by allowing sessions copying, like we do for
process group, but I'm not sure if that would be too secure to do it,
and if there would not be another similar resource in future.

We can use CABA not only for CRIU for restoring processes, in normal
life when processes detach CABA will help to understand from which place
in process tree they were originally started from sshd/crond or
something else.

Hope my idea is not completely insane =)

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
 kernel/exit.c                            |  50 ++-
 kernel/fork.c                            |   4 +
 tools/testing/selftests/Makefile         |   1 +
 tools/testing/selftests/caba/.gitignore  |   1 +
 tools/testing/selftests/caba/Makefile    |   7 +
 tools/testing/selftests/caba/caba_test.c | 501 +++++++++++++++++++++++
 tools/testing/selftests/caba/config      |   1 +
 12 files changed, 593 insertions(+), 6 deletions(-)
 create mode 100644 tools/testing/selftests/caba/.gitignore
 create mode 100644 tools/testing/selftests/caba/Makefile
 create mode 100644 tools/testing/selftests/caba/caba_test.c
 create mode 100644 tools/testing/selftests/caba/config

-- 
2.35.3
