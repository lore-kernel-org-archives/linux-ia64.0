From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 15:57:09 +0000
Subject: Re: load-store emulation with SIGSEGV (gate.S bug?)
Message-Id: <marc-linux-ia64-106640624521671@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106640456919155@msgid-missing>
In-Reply-To: <marc-linux-ia64-106640456919155@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Oct 2003 15:26:13 -0000, Jeffrey William Lake <lakes@lakes.plus.com> said:

  Jeffrey> After some investigation I discovered that a "flushrs" at
  Jeffrey> the start of my signal handler cured the problem.

  Jeffrey> Looking at "arch/ia64/kernel/gate.S" revealed that a
  Jeffrey> "cover" is used to get the registers onto the backing store
  Jeffrey> (commented as such several times), but by my understanding
  Jeffrey> there is enough scope from the instruction description that
  Jeffrey> they may be cached. Therefore, should gate.S include a
  Jeffrey> "flushrs" as well or, for performance reasons be left for
  Jeffrey> the user to decide?

There is no need to have a flushrs in gate.S.  If you want to access
the register-backing store in memory, you'll need to do a flushrs
anyhow.  BTW: you could use libunwind to access the registers, as that
would save you from having to know such details.  But of course it may
be a bit overkill (probably not too bad, though).

	--david
