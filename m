From: Matthew Wilcox <willy@debian.org>
Date: Thu, 31 Oct 2002 16:48:35 +0000
Subject: [Linux-ia64] Header dependencies
Message-Id: <marc-linux-ia64-105590709805316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I took a look at converting to the asm-offsets.c method for generating
offsets.h that the other architectures are using.  Basically, I ran
into the same problem Keith Owens alluded to earlier with the circular
dependencies:

asm/thread-info.h declares:
#define current_thread_info() ((struct thread_info *) ((char *) current + IA64_TASK_SIZE))
To get IA64_TASK_SIZE, it includes asm/offsets.h
To build asm/offsets.h, we need include linux/sched.h which includes
linux/thread_info.h which includes asm/thread_info.h.

I think the basic problem is that thread_info and task_struct are the
wrong way round on the stack.  If we put thread_info first then we don't
need IA64_TASK_SIZE in current_thread_info's definition.  What would
people think to this rearrangement?  I guess some asm code might need
to be changed, and I'm still scared of ia64 assembler ;-)

-- 
Revolutions do not require corporate support.

