From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Jul 2002 18:47:36 +0000
Subject: Re: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Jul 2002 11:02:25 -0700, Grant Grundler <grundler@cup.hp.com> said:

  Grant> Would "lazy TLB flushing" be possible?
  Grant> ie flush TLB of given taskid first time task needs to run on a CPU.
  Grant> Deal with the TLB flushing when running the task,
  Grant> not when creating or rescheduling to a different CPU.

There is no good way to distinguish between "running a task for the
first time on a CPU" and "rescheduling".  It could be done, but I
don't think it's worth the complexity.  The overhead of checking for a
delayed flush is just one load from a CPU-local variable and a test.
That's in the noise compared to a context-switch.

  Grant> I'm thinking broadcasting TLB flushes (or IPI for that
  Grant> effect) is, uhm, less than optimal for scalability. But I'm
  Grant> no expert on CPU TLB issues.  There might be lots of evils
  Grant> with this approach. I need to read the section on process
  Grant> creation/scheduling in the IA64 Linux book.  (ie you don't
  Grant> need to explain what the book already says).

With Erich's patch, there are no IPIs on wrap-around.  That was the
whole point of the patch (to avoid deadlock conditions).

	--david

