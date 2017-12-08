From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Dec 2017 15:51:59 +0000
Subject: [PATCH 5/5] Expand INIT_STRUCT_PID and remove
Message-Id: <151274831897.9961.5697313993537741716.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
In-Reply-To: <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org
Cc: dhowells@redhat.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org

Expand INIT_STRUCT_PID in the single place that uses it and then remove it.
There doesn't seem any point in the macro.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |   15 ---------------
 kernel/pid.c              |   14 +++++++++++++-
 2 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 5b5f41328115..a454b8aeb938 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -46,21 +46,6 @@ extern struct cred init_cred;
 #define INIT_CPU_TIMERS(s)
 #endif
 
-
-#define INIT_STRUCT_PID {						\
-	.count 		= ATOMIC_INIT(1),				\
-	.tasks		= {						\
-		{ .first = NULL },					\
-		{ .first = NULL },					\
-		{ .first = NULL },					\
-	},								\
-	.level		= 0,						\
-	.numbers	= { {						\
-		.nr		= 0,					\
-		.ns		= &init_pid_ns,				\
-	}, }								\
-}
-
 #define INIT_PID_LINK(type) 					\
 {								\
 	.node = {						\
diff --git a/kernel/pid.c b/kernel/pid.c
index b13b624e2c49..161af2eda943 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -41,7 +41,19 @@
 #include <linux/sched/task.h>
 #include <linux/idr.h>
 
-struct pid init_struct_pid = INIT_STRUCT_PID;
+struct pid init_struct_pid = {
+	.count 		= ATOMIC_INIT(1),
+	.tasks		= {
+		{ .first = NULL },
+		{ .first = NULL },
+		{ .first = NULL },
+	},
+	.level		= 0,
+	.numbers	= { {
+		.nr		= 0,
+		.ns		= &init_pid_ns,
+	}, }
+};
 
 int pid_max = PID_MAX_DEFAULT;
 

