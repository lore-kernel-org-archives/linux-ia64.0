From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 26 Jun 2001 16:12:26 +0000
Subject: Re: [Linux-ia64] volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005770@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005770@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 26 Jun 2001 17:34:52 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> include/asm-ia64/smp.h has 'extern unsigned long
  Andreas> cpu_online_map', but arch/ia64/kernel/setup.c and
  Andreas> arch/ia64/kernel/smpboot.c have 'volatile unsigned long
  Andreas> cpu_online_map'.  Which one is correct?

It should be volatile.  Apparently, there were some changes in the
gcc3.0 tree shortly before the final release which made gcc more picky
(at least I don't recall seeing those messages before).  Also, I think
there may be a new code generation problem in gcc3.0: the kernel gets
stuck in the middle of the boot (after the message "Starting up
secondaries").  I'll try to look into this soon, but I'm at Usenix the
rest of this week and on vacation right afterwards, so I may not get
to it until mid-July.  So it looks like gcc3.0 isn't as kernel-ready
as I thought it was.  Bummer.

	--david

