From: David Howells <dhowells@redhat.com>
Date: Thu, 20 Jul 2017 12:50:48 +0000
Subject: [PATCH 5/5] Unroll INIT_STRUCT_PID
Message-Id: <150055504878.20414.2817022733059449213.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <150055501157.20414.14957264566013145790.stgit@warthog.procyon.org.uk>
In-Reply-To: <150055501157.20414.14957264566013145790.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@kernel.org
Cc: linux-arch@vger.kernel.org, dhowells@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Unroll INIT_STRUCT_PID in the single place that uses it.  There doesn't
seem any point in the macro.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/init_task.h |   15 ---------------
 kernel/pid.c              |   15 ++++++++++++++-
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index fc51c709d19d..4d181cc252cf 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -46,21 +46,6 @@ extern struct cred init_cred;
 #endif
 
 
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
-		.pid_chain	= { .next = NULL, .pprev = NULL },	\
-	}, }								\
-}
-
 #define INIT_PID_LINK(type) 					\
 {								\
 	.node = {						\
diff --git a/kernel/pid.c b/kernel/pid.c
index 731c4e528f4e..d276a050d73e 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -44,7 +44,20 @@
 	hash_long((unsigned long)nr + (unsigned long)ns, pidhash_shift)
 static struct hlist_head *pid_hash;
 static unsigned int pidhash_shift = 4;
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
+		.pid_chain	= { .next = NULL, .pprev = NULL },
+	}, }
+};
 
 int pid_max = PID_MAX_DEFAULT;
 

