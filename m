From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Jan 2003 23:43:22 +0000
Subject: [Linux-ia64] Re: strace improvement patch
Message-Id: <marc-linux-ia64-105590709805652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805650@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805650@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 Jan 2003 14:17:06 -0800, Roland McGrath <roland@redhat.com> said:

  Roland> Thanks, David.  That original patch was indeed by me.  I am
  Roland> now doing most of the strace maintenance on the sourceforge
  Roland> version directly.

I'm very happy to hear that.  Seems like you have made lots of nice
improvements already.

  Roland> I was already planning to merge those changes in, along with
  Roland> some more clone-related changes I have to handle the 2.5
  Roland> threads stuff that I will finish up and merge.  I will
  Roland> incorporate your fixes and test it on IA64 before I commit
  Roland> those changes.

Thanks!

>>>>> On Wed, 8 Jan 2003 14:20:02 -0800, Roland McGrath <roland@redhat.com> said:

  >> Also, I'd recommend to use gcc-3.2 for compiling strace.  I
  >> encountered some strange bugs with gcc-2.96, though I did not try to
  >> track them down.  With gcc-3.2, those bugs went away and strace now
  >> seems to work quite nicely (once again, that is).

  Roland> Can you give me at least a clue what to look for?

Sure thing: what happened is that after an execve(), all syscall
result values would come out wrong (usually as 0x8000000000000000 or
-9223372036854775808).  It didn't always happen, and the problem
usually went away whenever I tried to track it down by adding printfs.
I think the problem was that strace got out of sync and thought that
the program was returning from a syscall when it was actually entering
it.

	--david

