From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 22:43:14 +0000
Subject: Re: [PATCH] turn off irqdebug by default on Altix
Message-Id: <16425.24194.621512.372011@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 5 Feb 2004 13:37:28 -0500, Martin Hicks <mort@sgi.com> said:

  Martin> How about this patch?  I just tested it on a 512p machine
  Martin> and it booted.

I suspect a better fix would be to change do_IRQ() such that it
doesn't call note_interrupt() for IRQ_PER_CPU interrupts.  For per-CPU
interrupts, the note_interrupt() code is racy and rather bogus anyhow.

	--david
