From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 07:12:49 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005312@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I disagree that de-optimizing the compiler output is the obvious solution.

In the case you describe, the return address will be equal to the end of
the scsi_malloc function and the beginning of the scsi_free function.  In 
that case, it should be obvious that we came from the scsi_malloc function.

You mention that the kernel sets b0 in some places.  But if the kernel is
setting b0 differently than a call instruction does, then the kernel must
be broken.  If the kernel is setting b0 to point someplace else to optimize
away a branch, then I don't understand how unwinding could work anyways,
because the unwind info will likely be different at the target than where
we are coming from.  I would need a really good description of what the
kernel is doing here before I could accept this as a valid reason to
de-optimize code.  If what the kernel is doing is valid, then why not
suggest that the kernel be modified to insert nops before the places where
the funny b0 stuff is done, so that b0-1 is still valid.

gdb does not use unwind info as yet, as far as I know.

We use the unwind info for C++ exceptions, but there would be no problem
there I think, because we already subtract one from the return address before
using it.

If I had enough time, I think I could create counterexamples showing that the
problem is not just noreturn calls.  What happens if we have a call immediately
followed by something like .body/.copy_state.  That would be pretty unlikly,
but it probably isn't impossible.  If you use the return address directly,
then you get the wrong unwind state.

Jim



