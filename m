From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 23:13:23 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16536.9107.246899.698701@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 15:58:32 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> But my point was: doesn't in/out hard fail on other ia64
  Jesse> platforms too?

No.  AFAIK, inX/outX is always supposed to soft-fail.  On zx1-based
machines, firmware initializes the chipset such that memory-mapped I/O
will hard-fail.  Intel chipsets will always softfail, even for
memory-mapped I/O.  Anybody knows what IBM's chipset does in this
regard?

  Jesse> Sure, that makes sense.  The other part of the implementation
  Jesse> was to deal with regular MMIO accesses though--userspace
  Jesse> drivers want to get signalled when an error occurs, would you
  Jesse> propose the page fault mechanism to detect that as well, or
  Jesse> is an MCA handler a better way to go?

I don't have a strong opinion on this particular issue.

	--david
