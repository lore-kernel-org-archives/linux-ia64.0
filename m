From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 06:21:49 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Dec 2000 16:13:06 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Wed, 13 Dec 2000 20:39:17 -0800, David Mosberger
  Keith> <davidm@hpl.hp.com> wrote:
  >> Note that the unwind code is written such that it cannot fault,
  >> even if the initial state on the stack is completely bogus.  This
  >> is why it's safe to call get_wchan() on a process that's running.

  Keith> Safe but it gives misleading results which confuse people
  Keith> doing debugging.  I had the same problem on kdb for ia32.
  Keith> Doing backtrace of the running process on cpu 0 from cpu 1
  Keith> (btp pid) gave different results compared to backtrace of the
  Keith> current process on cpu 0 (bt).  Debuggers should not give
  Keith> different results for the same process just because you are
  Keith> looking from another cpu.

Sure, kdb should do it's job right, but kdb is certainly no reason to
to hack the context switch code.  Not for something that 99.9% of the
users never even know existed.

	--david

