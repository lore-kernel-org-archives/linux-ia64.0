From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Sep 2002 19:41:36 +0000
Subject: Re: [Linux-ia64] Syscall tracing bug
Message-Id: <marc-linux-ia64-105590701906072@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906071@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906071@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Sep 2002 21:19:31 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> Is this a bug in strace or in the kernel (maybe
  Andreas> <asm/rse.h>)?

It's a bug in the strace you're using.  This was fixed a long time ago
in the CVS tree of strace.  I haven't updated my tree since Oct 2001,
but it has the right code: around line 1279 in syscall.c, it should
say something like this:

			sof = (cfm >> 0) & 0x7f;
			sol = (cfm >> 7) & 0x7f;
			out0 = ia64_rse_skip_regs(rbs_end, -sof + sol);

	--david

