From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Feb 2003 19:21:31 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805875@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805864@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Keith,

  Keith> This patch has been running inside SGI for 2 months.  It
  Keith> handles kernel stacks with multiple struct pt_regs, as found
  Keith> while debugging the kernel.  The debugging statements in the
  Keith> unwind code were awkward to use and inconsistent in what was
  Keith> being dumped and when, I ended up changing almost all the
  Keith> unwind debugging code while tracking down this problem.

The patch basically looks fine to me, except that I'd really like to
prefer to have it split up into one patch that does the pt_regs fixes
and one that does the debug enhancements.  And while you're at it,
please use something a bit more concise than UNW_DEBUG_PRINT
(something like DPRINT or UNW_DPRINT should be sufficient).

Thanks,

	--david

