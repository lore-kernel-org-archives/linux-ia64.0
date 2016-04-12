From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Tue, 12 Apr 2016 13:00:37 +0000
Subject: [PATCH] ia64: salinfo: use a waitqueue instead a sema down/up combo
Message-Id: <1460466037-4037-1-git-send-email-bigeasy@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The only purpose of down_try_lock() followed by up() seems to be to wake
up a possible reader. This patch replaces it with a wake-queue. There is
no locking around cpumask_empty() and the test is re-done in case there
was no hit.
With wait_event_interruptible_lock_irq(,&data_saved_lock) we would probably
be able to get rid of the `retry` label. However we still can return CPU
X which is valid now but later (after the lock dropped) the event may
have been removed because the CPU went offline.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---

I stumbled uppon this, beause I wanted to replace CPU_DEAD with
CPU_DOWN_PREPARE in order to make the states symmetrical.
I *think* the reason for CPU_DEAD is to drop all entries from the buffer
for a CPU that is now offline and since interrupts for this are off by
now there can be no more entries added to the buffer for this CPU.

Doing this at CPU_DOWN_PREPARE would open a small window where a 
per-CPU MCA interrupt could arise between CPU_DOWN_PREPARE and disabling
the interrupts.

And this brings me to the following question: Do you really want to drop all
entries for a CPU that goes offline? Wouldn't it make sense to keep that entry
even if the CPU is offline now? From what I understand MCA can send such an
interrupt / entry due to a memory error. Wouldn't it be important to keep this
information until userspace decides to remove it (despite the online state of
the CPU)?

 arch/ia64/kernel/salinfo.c | 38 ++++++++++----------------------------
 1 file changed, 10 insertions(+), 28 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 1eeffb7fbb16..5313007d5423 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -141,7 +141,7 @@ enum salinfo_state {
 
 struct salinfo_data {
 	cpumask_t		cpu_event;	/* which cpus have outstanding events */
-	struct semaphore	mutex;
+	wait_queue_head_t	read_wait;
 	u8			*log_buffer;
 	u64			log_size;
 	u8			*oemdata;	/* decoded oem data */
@@ -182,21 +182,6 @@ struct salinfo_platform_oemdata_parms {
 	int ret;
 };
 
-/* Kick the mutex that tells user space that there is work to do.  Instead of
- * trying to track the state of the mutex across multiple cpus, in user
- * context, interrupt context, non-maskable interrupt context and hotplug cpu,
- * it is far easier just to grab the mutex if it is free then release it.
- *
- * This routine must be called with data_saved_lock held, to make the down/up
- * operation atomic.
- */
-static void
-salinfo_work_to_do(struct salinfo_data *data)
-{
-	(void)(down_trylock(&data->mutex) ?: 0);
-	up(&data->mutex);
-}
-
 static void
 salinfo_platform_oemdata_cpu(void *context)
 {
@@ -258,7 +243,7 @@ salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe)
 	}
 	cpumask_set_cpu(smp_processor_id(), &data->cpu_event);
 	if (irqsafe) {
-		salinfo_work_to_do(data);
+		wake_up_interruptible(&data->read_wait);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
 }
@@ -271,14 +256,10 @@ extern void ia64_mlogbuf_dump(void);
 static void
 salinfo_timeout_check(struct salinfo_data *data)
 {
-	unsigned long flags;
 	if (!data->open)
 		return;
-	if (!cpumask_empty(&data->cpu_event)) {
-		spin_lock_irqsave(&data_saved_lock, flags);
-		salinfo_work_to_do(data);
-		spin_unlock_irqrestore(&data_saved_lock, flags);
-	}
+	if (!cpumask_empty(&data->cpu_event))
+		wake_up_interruptible(&data->read_wait);
 }
 
 static void
@@ -308,10 +289,11 @@ salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t
 	int i, n, cpu = -1;
 
 retry:
-	if (cpumask_empty(&data->cpu_event) && down_trylock(&data->mutex)) {
+	if (cpumask_empty(&data->cpu_event)) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
-		if (down_interruptible(&data->mutex))
+		if (wait_event_interruptible(data->read_wait,
+					     !cpumask_empty(&data->cpu_event)))
 			return -EINTR;
 	}
 
@@ -510,7 +492,7 @@ salinfo_log_clear(struct salinfo_data *data, int cpu)
 	if (data->state = STATE_LOG_RECORD) {
 		spin_lock_irqsave(&data_saved_lock, flags);
 		cpumask_set_cpu(cpu, &data->cpu_event);
-		salinfo_work_to_do(data);
+		wake_up_interruptible(&data->read_wait);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
 	return 0;
@@ -582,7 +564,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 		     i < ARRAY_SIZE(salinfo_data);
 		     ++i, ++data) {
 			cpumask_set_cpu(cpu, &data->cpu_event);
-			salinfo_work_to_do(data);
+			wake_up_interruptible(&data->read_wait);
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 		break;
@@ -640,7 +622,7 @@ salinfo_init(void)
 	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
 		data = salinfo_data + i;
 		data->type = i;
-		sema_init(&data->mutex, 1);
+		init_waitqueue_head(&data->read_wait);
 		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
 		if (!dir)
 			continue;
-- 
2.8.0.rc3

