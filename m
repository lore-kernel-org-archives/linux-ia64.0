From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Feb 2004 14:29:45 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <16443.24537.894757.554578@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 23:05:37 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I am seeing a Heisenbug in the 2.6.3 kernel unwind code.  The
  Keith> symptoms are that the backtrace terminates early, usually
  Keith> failing to unwind past an interrupt frame.

I haven't seen that in quite some time.

  Keith> Andreas, this _may_ be what you are seeing.

  Keith> Changing the config options (sn2->dig) makes backtrace work
  Keith> again.  Turning on UNW_DEBUG to debug the unwinder makes
  Keith> backtrace work again :(.  Adding 30 dummy functions (which
  Keith> only call printk and are never called themselves) to unwind.c
  Keith> makes the backtrace work again.

  Keith> That last one really worries me.  All it does is shift the
  Keith> position of the real unwind code within the kernel without
  Keith> changing the unwind code itself.  Looks like an uninitialised
  Keith> pointer somewhere.

  Keith> gcc version 3.2.3 20030502 (Red Hat Linux 3.2.3-24) GNU
  Keith> assembler version 2.14.90.0.4 (ia64-unknown-linux-gnu) using
  Keith> BFD version 2.14.90.0.4 20030523

It doesn't sound like a timing-related bug though, which is good news.
If you could reproduce the problem with Ski, that would almosts certainly
make it possible to root-cause it relatively quickly.

It might also be worthwhile to see if gcc 3.3.3 or 3.4 makes any difference.

	--david
