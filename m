From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 16 May 2001 18:49:36 +0000
Subject: Re: [Linux-ia64] hanging process cannot be killed
Message-Id: <marc-linux-ia64-105590693005596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005594@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005594@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 May 2001 18:55:20 +0200 (MEST), Erich Focht <focht@ess.nec.de> said:

  Erich> Hello, how can it happen that a process isn't killable with
  Erich> kill -9 any more?

Can happen easily if it's doing a non-interruptible sleep.

  Erich> I have encountered this a few times and from within kdb two
  Erich> processes seem to be in "run" state on the same CPU! The one
  Erich> marked as "current" shows the following traceback:
  Erich> __ia64_save_fpu+0x20 schedule+0xa40 invoke_schedule+0x20
  Erich> ia64_leave_kernel+0x30

  Erich> [snip...]

  Erich> I've seen this with 2.4.0 and 2.4.4 kernels, with B1 stepping
  Erich> CPUs. With 2.4.4 in single dispersal mode the problem doesn't
  Erich> seem to occur...

I'd recommend to upgrade to B3 or C0.  Earlier steppings had some
issues.  Most of them can be worked around, but it's not very pretty
and I'd not recommend spending a lot of time on it.

	--david

