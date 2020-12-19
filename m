From: Arnd Bergmann <arnd@kernel.org>
Date: Sat, 19 Dec 2020 09:24:42 +0000
Subject: [PATCH] ia64: fix timer cleanup regression
Message-Id: <20201219092516.1364230-1-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

A cleanup patch from my legacy timer series broke ia64 and led
to RCU stall errors and a fast system clock:

[  909.360108] INFO: task systemd-sysv-ge:200 blocked for more than 127 sec=
onds.
[  909.360108]       Not tainted 5.10.0+ #130
[  909.360108] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables =
this message.
[  909.360108] task:systemd-sysv-ge state:D stack:    0 pid:  200 ppid:   1=
89 flags:0x00000000
[  909.364108]
[  909.364108] Call Trace:
[  909.364423]  [<a00000010109b210>] __schedule+0x890/0x21e0
[  909.364423]                                 sp=E0000100487d7b70 bsp=E000=
0100487d1748
[  909.368423]  [<a00000010109cc00>] schedule+0xa0/0x240
[  909.368423]                                 sp=E0000100487d7b90 bsp=E000=
0100487d16e0
[  909.368558]  [<a00000010109ce70>] io_schedule+0x70/0xa0
[  909.368558]                                 sp=E0000100487d7b90 bsp=E000=
0100487d16c0
[  909.372290]  [<a00000010109e1c0>] bit_wait_io+0x20/0xe0
[  909.372290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1698
[  909.374168] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
[  909.376290]  [<a00000010109d860>] __wait_on_bit+0xc0/0x1c0
[  909.376290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1648
[  909.374168] rcu:     3-....: (2 ticks this GP) idle=19e/1/0x400000000000=
0002 softirq=1581/1581 fqs=3D2
[  909.374168]  (detected by 0, tV61 jiffies, g=1089, q=3D3)
[  909.376290]  [<a00000010109da80>] out_of_line_wait_on_bit+0x120/0x140
[  909.376290]                                 sp=E0000100487d7b90 bsp=E000=
0100487d1610
[  909.374168] Task dump for CPU 3:
[  909.374168] task:khungtaskd      state:R  running task

Revert most of my patch to make this work again, including the extra
update_process_times()/profile_tick() and the local_irq_enable() in the
loop that I expected not to be needed here.

I have not found out exactly what goes wrong, and would suggest that
someone with hardware access tries to convert this code into a singleshot
clockevent driver, which should give better behavior in all cases.

Reported-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Fixes: 2b49ddcef297 ("ia64: convert to legacy_timer_tick")
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Stephen Boyd <sboyd@kernel.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/kernel/time.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 9431edb08508..e3d9c8088d56 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -161,29 +161,34 @@ void vtime_account_idle(struct task_struct *tsk)
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
 {
-	unsigned long cur_itm, new_itm, ticks;
+	unsigned long new_itm;
=20
 	if (cpu_is_offline(smp_processor_id())) {
 		return IRQ_HANDLED;
 	}
=20
 	new_itm =3D local_cpu_data->itm_next;
-	cur_itm =3D ia64_get_itc();
=20
-	if (!time_after(cur_itm, new_itm)) {
+	if (!time_after(ia64_get_itc(), new_itm))
 		printk(KERN_ERR "Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)\=
n",
-		       cur_itm, new_itm);
-		ticks =3D 1;
-	} else {
-		ticks =3D DIV_ROUND_UP(cur_itm - new_itm,
-				     local_cpu_data->itm_delta);
-		new_itm +=3D ticks * local_cpu_data->itm_delta;
-	}
+		       ia64_get_itc(), new_itm);
+
+	while (1) {
+		new_itm +=3D local_cpu_data->itm_delta;
+
+		legacy_timer_tick(smp_processor_id() =3D time_keeper_id);
=20
-	if (smp_processor_id() !=3D time_keeper_id)
-		ticks =3D 0;
+		local_cpu_data->itm_next =3D new_itm;
=20
-	legacy_timer_tick(ticks);
+		if (time_after(new_itm, ia64_get_itc()))
+			break;
+
+		/*
+		 * Allow IPIs to interrupt the timer loop.
+		 */
+		local_irq_enable();
+		local_irq_disable();
+	}
=20
 	do {
 		/*
--=20
2.29.2
