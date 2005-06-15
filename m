From: Keith Owens <kaos@sgi.com>
Date: Wed, 15 Jun 2005 06:31:23 +0000
Subject: TLB corruption in 2.4.31 scenario?
Message-Id: <16182.1118817083@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mario cannot get to the ia64 list, so I am forwarding this for him.
Please cc Mario on any replies.

------- Forwarded Message

  I noticed during a do_fork() -> copy_mm() -> dup_mmap()  - flush_tlb_mm()
gets called that clears current->mm->context. Now if on another
CPU is running wrap_mmu_context() it can potenitally
step over this context number and assign an alias context to
a new task, then there is a window between the flushing of
the TLB and some other task getting its new context
assigned and returning to user space.  Do you think
there is potential here?

The question comes from TLB aliasing like core files that
I've analyzed. We have not been able to isolate this to
a self-contained executable so the next best thing I could
do is read the code, the issue is very critical for us.

I'd appreciate any insights you may have, btw I can't get
on the ia64 maillist for some reason.


- mario



------- End of Forwarded Message


