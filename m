From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Feb 2004 02:54:48 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <16442.48376.516222.660650@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 Darren> Hi David
 Darren> PCI_DMA_BUS_IS_PHYS to 0

 Darren> boots OK

 Darren> PCI_DMA_BUS_IS_PHYS Oxffffffff
 Darren> &
 Darren> PCI_DMA_BUS_IS_PHYS OxffffffffUL

 Darren> fail

Sorry, apparently I wasn't clear: PCI_DMA_BUS_IS_PHYS is a boolean, so
it makes no sense to set it to anything other than 0 or 1.  What I
meant for the second option is to leave PCI_DMA_BUS_IS_PHYS to 1 and
then to set the ISA_DMA_THRESHOLD to 0xffffffff.

 Darren> Before continuing with this there are more serious problems
 Darren> with the slab layer, see my post (BUG) slab error....

I saw your mails, but haven't seen this problem myself.

	--david
