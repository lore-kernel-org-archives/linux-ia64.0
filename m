From: Duraid Madina <duraid@kinoko.c.u-tokyo.ac.jp>
Date: Wed, 06 Apr 2005 02:13:30 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID with kernel 2.6.11
Message-Id: <20050406021330.GA59371@kinoko.c.u-tokyo.ac.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 05, 2005 at 01:25:40PM -0700, David Mosberger wrote:
> >>>>> On Tue, 05 Apr 2005 20:11:51 +0200, Andreas Hirstius <Andreas.Hirstius@cern.ch> said:
> 
> Is there any reason to believe this change in behavior is
> ia64-specific?  I doubt it.

Probably not ia64-specifc again, but I wonder what you make of
http://bugme.osdl.org/show_bug.cgi?idB68 . The LSI MPT scsi hosts
are _particularly_ prevalent in the ia64 world.

	Duraid
