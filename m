From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Tue, 19 Aug 2008 22:19:39 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080819221939.GC11599@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA30844B26C@orsmsx505.amr.corp.intel.com> <20080813162553.GA5720@elte.hu> <20080813192909.GA31685@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA3084A65FD@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3084A65FD@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 13.08.2008 [13:11:45 -0700], Luck, Tony wrote:
> > Well Peter's patch was tested-by me, so I know it fixes the problem on
> > the box I have access to, I'm verifying that -rc3 is ok.
> >
> > Tony, would you like me to test your patch in isolation (reverting
> > c1955a3d4762e7a9bf84035eb3c4886a900f0d15) to see if it also fixes it?
> 
> It would be nice to know ... I expect that you'll see crazy numbers
> for the timestamps on the first few printk()s without Peter's fix (I
> did on my system).

Sorry for the delay.

Yes, your patch in isolation (having reverted Peter's
c1955a3d4762e7a9bf84035eb3c4886a900f0d15) allows this box to boot
2.6.27-rc3 with CONFIG_PRINTK_TIME=y. As you noted, I did see some
oddities in the printk timings, where the values would go up then back
down, but nothing further out of the ordinary.

Thanks,
Nish

P.S. Should I start a separate thread on the messages I mentioned
earlier (but only in passing)?

[   32.593534] kernel unaligned access to 0xe000000644220466, ip=0xa000000100516fa1
[   32.601171] kernel unaligned access to 0xe00000064422046e, ip=0xa000000100516fa1
[   35.333273] kernel unaligned access to 0xe00000064451693e, ip=0xa000000100516fa1
[   35.340912] kernel unaligned access to 0xe000000644516942, ip=0xa000000100516fa1
[   35.348557] kernel unaligned access to 0xe000000644516946, ip=0xa000000100516fa1

Box seems fine even with those messages.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
