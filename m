From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Oct 2001 00:56:18 +0000
Subject: [Linux-ia64] Re: [patch] fix unaligned references inside s/w pipelined loops
Message-Id: <marc-linux-ia64-105590698805366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Oct 2001 08:54:08 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> If an application takes an unaligned trap on a "rotating"
  Tony> register inside a software pipelined loop[1], then the kernel
  Tony> will use the wrong register when it fixes the fault.  This
  Tony> results in corrupted memory or register depending on whether
  Tony> the unaligned reference was a store or a load respectively.

  Tony> Attached is a patch to fix this (both for the integer case,
  Tony> which was the one actually reported to me, and the floating
  Tony> point case too).  Patch is against 2.4.10.

Looks good to me.  Patch applied.

  Tony> [1] Don't ask me why someone would go through all the effort
  Tony> of writing a s/w pipelined loop, but not check for unaligned
  Tony> access, I don't understand it either ... but they did.

Well, I can think of one reason: it could make sense if the data
happens to be aligned properly 99.9% of the time.  In any case, this
was definitely a bug.  Thanks for fixing it.

	--david

