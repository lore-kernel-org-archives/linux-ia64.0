From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 09 Feb 2003 18:22:33 +0000
Subject: Re: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805824@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805824@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 9 Feb 2003 21:55:50 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> I'll explain the context.  I've written a virtual machine
  Matt> monitor which currently (for ease of prototyping) runs
  Matt> completely in userspace.  e.g. itc does an mmap, ptc does an
  Matt> munmap, changing RID unmaps a whole region, SIGSEGV delivers a
  Matt> TLB miss to the "guest" kernel.

  Matt> Now after a flush or RID change the guest kernel returns to
  Matt> its userspace with ar.bspstore pointing off to somewhere that
  Matt> isn't mapped, expecting to get a fault eventually.  This is
  Matt> where the problem occurs.  A mandatory RSE load faults as
  Matt> expected and the kernel tries to deliver SIGSEGV.  But then
  Matt> the RFI to the signal trampoline repeats the same RSE load
  Matt> that caused the fault in the first place, before the signal
  Matt> handler can deal with it.

Ah, that does sound interesting.

Actually, my explanation from yesterday can't be right: the current
register frame as of the time of the mandatory RSE fault by definition
is NOT on the user backing store, so the "rfi" shouldn't trigger any
mandatory loads (the user's current frame is restored by the "loadrs"
in the kernel's exit path).

  Matt> Is there any reason that the signal trampoline needs to see
  Matt> the original frame, or would it suffice to give it an empty
  Matt> frame?  (Hmm, presumably this would mean filling out sc_cfm in
  Matt> the kernel...  how to do that if we're in a syscall and
  Matt> haven't done the cover?)

Someone needs to take care of backing the user's dirty partition.
Since the user's original stack may not be valid, it needs to be
backed by the alternate signal stack.  That's most easily done by the
signal trampoline after switching to the new backing store.

I'm not sure off-hand what's wrong.  I'll take a look Monday.  For
what it's worth, the test program does seem to work fine on 2.5.52.

	--david

