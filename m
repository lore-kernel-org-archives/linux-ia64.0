From: Yury Norov <yury.norov@gmail.com>
Date: Mon, 31 Jan 2022 01:46:48 +0000
Subject: [PATCH] kernel/cpu.c: fix init_cpu_online
Message-Id: <20220131014648.941629-1-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Valentin Schneider <valentin.schneider@arm.com>, Vincent Donnefort <vincent.donnefort@arm.com>, Ingo Molnar <mingo@kernel.org>, YueHaibing <yuehaibing@huawei.com>, Yuan ZhaoXiong <yuanzhaoxiong@baidu.com>, Randy Dunlap <rdunlap@infradead.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Yury Norov <yury.norov@gmail.com>

cpu_online_mask has an associate counter of online cpus, which must be
initialized in init_cpu_online().

Fixes: 0c09ab96fc82010 (cpu/hotplug: Cache number of online CPUs)
Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 kernel/cpu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/cpu.c b/kernel/cpu.c
index 407a2568f35e..cd7605204d4d 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -2616,6 +2616,7 @@ void init_cpu_possible(const struct cpumask *src)
 void init_cpu_online(const struct cpumask *src)
 {
 	cpumask_copy(&__cpu_online_mask, src);
+	atomic_set(&__num_online_cpus, cpumask_weight(cpu_online_mask));
 }
 
 void set_cpu_online(unsigned int cpu, bool online)
-- 
2.30.2
