From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Feb 2004 05:01:45 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <16437.38073.58872.657843@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Feb 2004 13:55:08 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:

  Darren> Hi David I will try the first option of setting

  Darren> PCI_DMA_BUS_IS_PHYS to 0

  Darren> and report back.

OK.  It would be interesting to know whether the ISA_DMA_THRESHOLD
fix also works, since that would be more likel to qualify as a permanent
fix.

  Darren> I know we must be the only people in the world that uses
  Darren> these machines, but somebody has to keep the HP service guys
  Darren> clued up on old technology. The last guy that payed us a
  Darren> visit though he was in a museum.

Heh.. ;-)

There is no need to feel apologetic though: the Intel Tiger platform
should have the same issue.

	--david
