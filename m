From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 22 Mar 2001 23:51:59 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005341@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Mar 2001 14:18:15 -0800, Jim Wilson <wilson@cygnus.com> said:

  >> o Modified the exception table format to take advantage of local
  >> tags if they're support.  To take full advantage of this, a
  >> gcc3.0 based toolchain would be necessary.  However,

  Jim> Actually, this is a binutils feature.  The version of gcc that
  Jim> you have is irrelevant.  This might matter because not
  Jim> everybody uses the same binutils version with the same gcc
  Jim> version.  You need a binutils from last week or newer.  This
  Jim> patch will be in binutils 2.11.

Yes, I know.  However, AFAIK, there is no easy way to check the
binutils version inside assembly code, so I'm using __GNUC__ >= 3 in
the kernel for lack of a better test.  I'm assuming that by the time
3.0 is released, everybody will be using binutils 2.11 or newer.

  >> However, the prerelease version of this compiler is NOT yet
  >> stable enough for kernel use.  So even though you find a bunch of
  >> "#if __GNUC__ >= 3" in the patch, I do not recommend building
  >> with this compiler at this time.

  Jim> Is there a particular reason why we can't use gcc3 yet?

Yes.  I reported a bug related to stop bit generation a week ago or so
to both you and Bernd.  This bug causes the kernel to crash.  Bernd
has been working on it.  I sent him a suggstion for a fix today but
haven't heard back yet.  Until that bug gets fixed, gcc3 is definitely
not usable for the kernel.

I also believe that gcc3 may be the source of a failure in the IA-32
subsystem of the kernel.  The effect is that certain IA-32 binaries
don't work properly.  But I have not had time to investigate further.

There could be other problems that start to show once we stress things
a bit more.  Also, I still need to check that the
copy_state/label_state fix that you implemented recently really does
work with the kernel unwinder.  AFAIK, this fix hasn't been checked
into the CVS branch yet, so as long as this hasn't happened, trying to
use gcc3 would hang the kernel, e.g., when creating a core dump.

  Jim> I know that there is a problem with unwind info when a
  Jim> particular optimization occurs, however, the exact same bug is
  Jim> present in the compiler that everyone is already using.  The
  Jim> only difference is that -freorder-blocks is the default with
  Jim> the current compiler, but was not the default when I branched
  Jim> the stable compiler.  Thus if this is the only problem, then
  Jim> the kernel will work fine if you use -fno-reorder-blocks.  This
  Jim> problem is on my short list, I have a patch that fixes the
  Jim> unwind info, but I also need to write a patch to fix the C++ EH
  Jim> unwinder.

Ah, I don't think you mentioned -fno-reorder-blocks as a possible
workaround before.  I suppose we could do that. However, I'd rather
not de-optimize the code unnecessarily, especially given that you have
a fix already.  It worries me that you let C++ EH hold up this bug
fix.  The unwinder in gcc is incomplete.  It will certainly fail when
mixed with output from other compilers and I'm quite certain you could
construct a test case where it would fail even on code produced with
today's gcc.  In other words, we might just as well admit to the gcc
unwinder being broken.

	--david

