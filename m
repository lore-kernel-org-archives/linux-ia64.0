From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 12 Jan 2002 03:13:47 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805817@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Nick> I'm trying to get Ingo's scheduler working on IA64 but I've hit a 
  Nick> dead-end with the head.S code.  Ingo's patch removes init_tasks,
  Nick> so I've modified the assembly in head.S to point at 
  Nick> runqueues(cpu)->idle, I think - it dies very early in the boot, 
  Nick> and I'm not familiar with ia64 assembly.

  Nick> Other issues, I had to build offsets.h by hand, and I moved some
  Nick> stuff from sched.c to sched.h.  Other than that, it's H6 + ia64.

  Nick> Anyone have any feedback on getting this booting?

This may not help you but just fyi: I'm planning to sync up with 2.5
next week (2.5.2 by then, hopefully).  Of course, if someone else has
a working patch by then, I'll take it. ;-)

	--david

