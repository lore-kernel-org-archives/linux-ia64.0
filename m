From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 05:20:26 +0000
Subject: Re: 2.6.3 oops ia64 Itanium1 with Silicon Image IDE
Message-Id: <16448.9498.355351.971420@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220005623.GI11475@cse.unsw.EDU.AU>
In-Reply-To: <20040220005623.GI11475@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Feb 2004 12:30:51 +1100, Darren Williams <dsw@gelato.unsw.edu.au> said:

  Darren> Hi David So with the correct changes the patch below boots
  Darren> with the 32bit pci silicon image ide controller and 4GB of
  Darren> ram on Itanium 1.

OK, I made this change now.  I tried to reproduce it on one of our
machines, but it turns out that none of them have both memory above
4GB and IDE disks (CD-ROMs don't trigger the BUG_ON).  This also
explains why we haven't seen any problems on our Tiger: even though it
has no hardware I/O MMU and memory above 4GB, it has only an IDE
CD-ROM, not an IDE harddisk.

Thanks,

	--david
