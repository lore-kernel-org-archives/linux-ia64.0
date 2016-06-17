From: Waiman Long <Waiman.Long@hpe.com>
Date: Fri, 17 Jun 2016 15:41:36 +0000
Subject: [RFC PATCH-tip/locking/core v3 10/10] locking/rwsem: Add a boot parameter to reader spinning thresho
Message-Id: <1466178096-5623-11-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

The default reader spining threshold is current set to 4096. However,
the right reader spinning threshold may vary from one system to
another and among the different architectures. This patch adds a new
kernel boot parameter to modify the threshold value. This enables
better tailoring to the needs of different systems as well as for
testing purposes.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 Documentation/kernel-parameters.txt |    3 +++
 kernel/locking/rwsem-xadd.c         |   14 +++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 82b42c9..3bee995 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3645,6 +3645,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	rw		[KNL] Mount root device read-write on boot
 
+	rwsem_rspin_threshold+			[KNL] Set rw semaphore reader spinning threshold
+
 	S		[KNL] Run init in single mode
 
 	s390_iommu=	[HW,S390]
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index c6b6105..6360180 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -280,6 +280,18 @@ static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
+ * Reader spinning threshold
+ */
+static int __read_mostly rspin_threshold = RWSEM_RSPIN_THRESHOLD;
+
+static int __init set_rspin_threshold(char *str)
+{
+	get_option(&str, &rspin_threshold);
+	return 0;
+}
+early_param("rwsem_rspin_threshold", set_rspin_threshold);
+
+/*
  * Try to acquire write lock before the writer has been put on wait queue.
  */
 static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
@@ -402,7 +414,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 	if (!osq_lock(&sem->osq))
 		goto done;
 
-	rspin_cnt = sem->rspin_enabled ? RWSEM_RSPIN_THRESHOLD : 0;
+	rspin_cnt = sem->rspin_enabled ? rspin_threshold : 0;
 
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
-- 
1.7.1

