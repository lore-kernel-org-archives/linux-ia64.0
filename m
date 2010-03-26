From: Julia Lawall <julia@diku.dk>
Date: Fri, 26 Mar 2010 22:02:47 +0000
Subject: [PATCH 3/7] arch/ia64/sn/kernel: Use set_cpus_allowed_ptr
Message-Id: <Pine.LNX.4.64.1003262302250.6480@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: peterz@infradead.org, mingo@elte.hu, tglx@linutronix.de, oleg@redhat.com, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use set_cpus_allowed_ptr rather than set_cpus_allowed.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1,E2;
@@

- set_cpus_allowed(E1, cpumask_of_cpu(E2))
+ set_cpus_allowed_ptr(E1, cpumask_of(E2))

@@
expression E;
identifier I;
@@

- set_cpus_allowed(E, I)
+ set_cpus_allowed_ptr(E, &I)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -629,9 +629,9 @@ static int sn_hwperf_op_cpu(struct sn_hw
 		else {
 			/* migrate the task before calling SAL */ 
 			save_allowed = current->cpus_allowed;
-			set_cpus_allowed(current, cpumask_of_cpu(cpu));
+			set_cpus_allowed_ptr(current, cpumask_of(cpu));
 			sn_hwperf_call_sal(op_info);
-			set_cpus_allowed(current, save_allowed);
+			set_cpus_allowed_ptr(current, &save_allowed);
 		}
 	}
 	r = op_info->ret;
