From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Apr 2005 16:58:26 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID
Message-Id: <16980.5426.929457.189464@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 06 Apr 2005 10:33:07 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:

  Andreas> But the driver in questions is 3w-9xxx and there have been
  Andreas> no chances at all in this driver between 2.6.10 and
  Andreas> 2.6.12-rc1. The changed driver in -rc2 still has the
  Andreas> problem.  And I've tried the driver built-in and as a
  Andreas> module (default)...

Are you sure the problem is due to the driver and not RAID0?  What if
you dd directly from the underlying device?

	--david
