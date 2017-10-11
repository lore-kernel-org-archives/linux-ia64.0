From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:01:56 +0000
Subject: [PATCH v6 05/11] locking/rwsem: Move rwsem internal function declarations to rwsem-xadd.h
Message-Id: <1507744922-15196-6-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

We don't need to expose rwsem internal functions which are not supposed
to be called directly from other kernel code.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/rwsem.h       | 7 -------
 kernel/locking/rwsem-xadd.h | 7 +++++++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index d0f59df..32389ee 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -42,13 +42,6 @@ struct rw_semaphore {
 #endif
 };
 
-extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
-extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
-
 #define RWSEM_UNLOCKED_VALUE	0
 
 /* In all implementations count != 0 means locked */
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 4c19539..9b30f0c 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -90,6 +90,13 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 
 #define RWSEM_COUNT_IS_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
 
+extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
+extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
+
 /*
  * lock for reading
  */
-- 
1.8.3.1

