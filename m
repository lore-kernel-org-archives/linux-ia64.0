From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 07:54:44 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 20 Mar 2001 23:12:49 -0800, Jim Wilson <wilson@cygnus.com> said:

  Jim> But if the kernel is setting b0 differently than a call
  Jim> instruction does, then the kernel must be broken.  If the
  Jim> kernel is setting b0 to point someplace else to optimize away a
  Jim> branch, then I don't understand how unwinding could work
  Jim> anyways, because the unwind info will likely be different at
  Jim> the target than where we are coming from.  I would need a
  Jim> really good description of what the kernel is doing here before
  Jim> I could accept this as a valid reason to de-optimize code.

The code path needed to leave the kernel is shared for all types of
interruptions.  Before calling an interruption handler, the kernel
arranges things so that the handler will return directly to the shared
exit path, instead of returning to the call site first.  This works
fine because the unwind state at the call site and return site are
always the same.

  Jim> If what the kernel is doing is valid, then why not suggest that
  Jim> the kernel be modified to insert nops before the places where
  Jim> the funny b0 stuff is done, so that b0-1 is still valid.

I also doubt that adding "nop"s in the compiler is the right solution.
There is only one place in the kernel that the short-circuit return is
done, so that should be easily fixable.

  Jim> We use the unwind info for C++ exceptions, but there would be
  Jim> no problem there I think, because we already subtract one from
  Jim> the return address before using it.

Perhaps that is the right solution.  But I need to think about this
some more.

	--david

