From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 09 Feb 2003 05:27:54 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805825@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 9 Feb 2003 16:19:20 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> I'm having some difficulty "demand paging" register backing
  Matt> store from userspace (i.e. using SIGSEGV to map pages in on
  Matt> demand).

  Matt> The problem is that even when using sigaltstack, the original
  Matt> backing store (which caused the fault) is still touched when
  Matt> returning to the signal trampoline, before it switches to the
  Matt> alternate RBS.  Thus I get recursive faulting before it gets
  Matt> to the signal handler.

  Matt> Ideally, signal handling on an alternate RBS/stack wouldn't
  Matt> touch the original RBS/stack at all.

  Matt> Any suggestions how to deal with this?

It sounds like you're using an old kernel.  I don't recall exactly
when this was fixed, but recent kernels will put the dirty partition
on the _new_ stack, not the old one.

You can check gate.S:ia64_sigtramp().  If it branches to "setup_rbs"
_before_ the first "alloc" instruction, you should be fine.

	--david

