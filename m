From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 23 Mar 2001 05:17:14 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005343@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Mar 2001 20:26:24 -0800, Jim Wilson <wilson@cygnus.com> said:

  >> Yes.  I reported a bug related to stop bit generation a week ago
  >> or so to both you and Bernd.

  Jim> It was only 3 days ago, but yeah, that needs to be fixed as
  Jim> soon as possible.

;-)

  Jim> I agree that the gcc unwinder is complete.  However, I don't
  Jim> think you are being fair when considering C++ EH.  You
  Jim> personally care only about the kernel unwinder.  But there are
  Jim> probably more people who care about C++ EH than whether the
  Jim> kernel can use an unwinder.

No, I do care about C++ programs working properly, even if I don't use
the language myself.  However, as far as I know, your patch emits
label_state/copy_state only where strictly needed, so if a C++ program
fails because of those directives, it either would have failed to
unwind the stack anyhow or it just got lucky.  I'd argue that either
situation is unacceptable, independent of whether or not a test suite
can catch them.  In other words, if all your patch does is trigger
latent bugs, I don't think it's worth holding it up.

  Jim> Also, there are FSF rules and regulations that I need to follow
  Jim> here.  Official FSF policy is that I can't check in a patch
  Jim> that causes regressions to the compiler.  There are of course
  Jim> exceptions to the rule, but they have to be used very
  Jim> carefully.  C++ EH regressions count in this consideration.
  Jim> Kernel unwinder regressions do not.  Thus it is best if I fix
  Jim> C++ EH regressions before checking in the patch.

Sounds reasonable.  But I hope you don't mind if I recommend against
using gcc3 for the kernel until the things I mentioned get fixed.

Incidentally, I think you mentioned that someone is considering to
implement the unwind api proposed by the C++ ABI.  Is the plan to use
the gcc unwinder as the engine behind this api?  Also, is anyone
actively working on this now?  It's very important that we have a
solid user-level unwinder as C, C++, Java, gdb, and even ski all have
a need for this (you may be surprised to see C in this list, but we
need it when someone wants to modify a "preserved" register in the
sigcontext of a signal handler).

	--david

