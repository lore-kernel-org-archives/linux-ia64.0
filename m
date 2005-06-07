From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 07 Jun 2005 17:31:59 +0000
Subject: Re: [PATCH] MAX_USER_RT_PRIO and MAX_RT_PRIO are wrong!
Message-Id: <1118165519.5667.3.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1118112390.4533.10.camel@localhost.localdomain>
	 <20050607053306.GA16181@elte.hu>
	 <1118143504.4533.21.camel@localhost.localdomain>
	 <20050607154846.GA1253@sgi.com>
In-Reply-To: <20050607154846.GA1253@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@SGI.com>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-altix@SGI.com, edwardsg@SGI.com, linux-kernel@vger.kernel.org, akpm@osdl.org, anton.wilson@camotion.com

On Tue, 2005-06-07 at 10:48 -0500, Dean Nelson wrote:
> You are correct xpc_activating() needs to be changed to use MAX_RT_PRIO.
> So please do add that change to your patch.

I haven't tested this patch, I just used the previous patch (which I did
test) and added your change.

-- Steve

--- linux-2.6.12-rc6/kernel/sched.c.orig	2005-06-07 13:22:33.000000000 -0400
+++ linux-2.6.12-rc6/kernel/sched.c	2005-06-07 13:22:37.000000000 -0400
@@ -3347,7 +3347,7 @@
 	p->policy = policy;
 	p->rt_priority = prio;
 	if (policy != SCHED_NORMAL)
-		p->prio = MAX_USER_RT_PRIO-1 - p->rt_priority;
+		p->prio = MAX_RT_PRIO-1 - p->rt_priority;
 	else
 		p->prio = p->static_prio;
 }
@@ -3379,7 +3379,8 @@
 	 * 1..MAX_USER_RT_PRIO-1, valid priority for SCHED_NORMAL is 0.
 	 */
 	if (param->sched_priority < 0 ||
-	    param->sched_priority > MAX_USER_RT_PRIO-1)
+	    (p->mm &&  param->sched_priority > MAX_USER_RT_PRIO-1) ||
+	    (!p->mm && param->sched_priority > MAX_RT_PRIO-1))
 		return -EINVAL;
 	if ((policy = SCHED_NORMAL) != (param->sched_priority = 0))
 		return -EINVAL;
--- linux-2.6.12-rc6/arch/ia64/sn/kernel/xpc_main.c.orig	2005-06-07 13:23:26.000000000 -0400
+++ linux-2.6.12-rc6/arch/ia64/sn/kernel/xpc_main.c	2005-06-07 13:23:43.000000000 -0400
@@ -420,7 +420,7 @@
 	partid_t partid = (u64) __partid;
 	struct xpc_partition *part = &xpc_partitions[partid];
 	unsigned long irq_flags;
-	struct sched_param param = { sched_priority: MAX_USER_RT_PRIO - 1 };
+	struct sched_param param = { sched_priority: MAX_RT_PRIO - 1 };
 	int ret;
 
 



