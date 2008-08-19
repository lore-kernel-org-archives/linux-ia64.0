From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 19 Aug 2008 22:34:18 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309E6FF01@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
 <57C9024A16AD2D4C97DC78E552063EA30844B26C@orsmsx505.amr.corp.intel.com>
 <20080813162553.GA5720@elte.hu> <20080813192909.GA31685@us.ibm.com>
 <57C9024A16AD2D4C97DC78E552063EA3084A65FD@orsmsx505.amr.corp.intel.com>
 <20080819221939.GC11599@us.ibm.com>
In-Reply-To: <20080819221939.GC11599@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Yes, your patch in isolation (having reverted Peter's
> c1955a3d4762e7a9bf84035eb3c4886a900f0d15) allows this box to boot
> 2.6.27-rc3 with CONFIG_PRINTK_TIME=y. As you noted, I did see some
> oddities in the printk timings, where the values would go up then back
> down, but nothing further out of the ordinary.

Good.  Thanks a lot for testing.

> P.S. Should I start a separate thread on the messages I mentioned
> earlier (but only in passing)?
>
> [   32.593534] kernel unaligned access to 0xe000000644220466, ip=0xa000000100516fa1

Separate thread sounds like a good idea.  You should decode the
ip=value to which routine was running. Look at System.map to get
the routine name, or use "objdump -d" to disassamble your vmlinux
to find the exact instruction (but note that the kernel indicates
the instruction in the bundle with a low order digit of 0, 1, 2
whereas the objdump disassembly uses 0, 6, c).

-Tony
