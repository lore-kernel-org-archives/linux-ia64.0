From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Sep 2003 14:59:11 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106432969621427@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Sep 2003 03:51:18 -0700, "David S. Miller" <davem@redhat.com> said:

  David> On Tue, 23 Sep 2003 20:40:05 +1000 Peter Chubb
  David> <peter@chubb.wattle.id.au> wrote:

  >> How expensive is it to take the trap and do a fix up, compared to
  >> making an aligned copy?  As it involves raising and handling a
  >> fault disassembling the instruction that caused the fault, etc.,
  >> I'd be surprised if it's much less than 1000 cycles, even without
  >> the printk, although I haven't measured it yet, and can't find
  >> enough info in the architecture manuals to know what it is.

  David> A cache miss can cause 100 or so cycles. :)

  David> And unlike the fixup trap, the printk wakes up a process and
  David> causes disk activity as syslogd writes to the kernel message
  David> log file.

The printk() is rate-controlled and doesn't happen for every unaligned
access.  It's average cost can be made as low as we want to, by adjusting
the rate.

	--david

