From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Apr 2005 04:45:34 +0000
Subject: Re: [Gelato-technical] Serious performance degradation on a RAID with
Message-Id: <16979.26990.264288.730071@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Apr 2005 11:13:30 +0900, Duraid Madina <duraid@kinoko.c.u-tokyo.ac.jp> said:

  Duraid> On Tue, Apr 05, 2005 at 01:25:40PM -0700, David Mosberger
  Duraid> wrote:
  >> >>>>> On Tue, 05 Apr 2005 20:11:51 +0200, Andreas Hirstius
  >> <Andreas.Hirstius@cern.ch> said:

  >> Is there any reason to believe this change in behavior is
  >> ia64-specific?  I doubt it.

  Duraid> Probably not ia64-specifc again, but I wonder what you make
  Duraid> of http://bugme.osdl.org/show_bug.cgi?idB68 . The LSI MPT
  Duraid> scsi hosts are _particularly_ prevalent in the ia64 world.

Did you compile the driver as a module?  If so, this should be of
interest:

 http://linux.bkbits.net:8080/linux-2.5/cset@4241a3b18VBJETehoTH3y5vcZilSwA

	--david
