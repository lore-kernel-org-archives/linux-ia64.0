From: Roland McGrath <roland@redhat.com>
Date: Sat, 23 Oct 2004 04:53:43 +0000
Subject: Re: ptrace problem in 2.6.9
Message-Id: <200410230453.i9N4rhHM028332@magilla.sf.frob.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Stephane Eranian's message of  Friday, 22 October 2004 10:05:57 -0700 <20041022170557.GW19372@frankl.hpl.hp.com>
References: <20041022170557.GW19372@frankl.hpl.hp.com>
In-Reply-To: <20041022170557.GW19372@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>

This is indeed a new bug, and it is not architecture-specific.  In my
recent changes to close some race conditions, I overlooked the case of a
process using PTRACE_ATTACH on its own children.  The new PT_ATTACHED flag
does not really mean "PTRACE_ATTACH was used", it means "PTRACE_ATTACH is
changing the ->parent link".  This patch fixes the problem that your test
program demonstrates.


Thanks,
Roland

Signed-off-by: Roland McGrath <roland@redhat.com>

--- linux-2.6/kernel/ptrace.c 19 Oct 2004 06:12:06 -0000 1.38
+++ linux-2.6/kernel/ptrace.c 23 Oct 2004 04:43:20 -0000
@@ -132,7 +132,8 @@ int ptrace_attach(struct task_struct *ta
 		goto bad;
 
 	/* Go */
-	task->ptrace |= PT_PTRACED | PT_ATTACHED;
+	task->ptrace |= PT_PTRACED | ((task->real_parent != current)
+				      ? PT_ATTACHED : 0);
 	if (capable(CAP_SYS_PTRACE))
 		task->ptrace |= PT_PTRACE_CAP;
 	task_unlock(task);
