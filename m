From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 08:06:18 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16446.64123.86.545496@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 Feb 2004 18:44:38 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "Scott" = Scott Feldman <Feldman> writes:

  >>> Is this related to NAPI?

  >>> I'll assume "the gigabit" card is e1000:

  Peter> Nope, DP83820.  I'm benchmarking a driver that runs in
  Peter> userspace against the in-kernel driver; both benefit from the
  Peter> interrupt speedup.

So why is irq enabling/disabling on the critical path for this driver?

	--david
