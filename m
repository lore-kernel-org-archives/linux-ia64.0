From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sun, 14 Mar 2004 05:22:42 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <16467.60450.471487.490560@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>
	<20040313034840.GF4638@wotan.suse.de>
	<20040313054910.GA655@holomorphy.com>
	<20040313161010.GB15118@wotan.suse.de>
	<20040314000506.GE655@holomorphy.com>
In-Reply-To: <20040314000506.GE655@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

>>>>> "William" = William Lee Irwin, <William> writes:

William> At some point in the past, I wrote:

William> On Sat, Mar 13, 2004 at 05:10:10PM +0100, Andi Kleen wrote:
>> Redesigning the low level TLB fault handling for this would not
>> count as "easily" in my book.

William> I make no estimate of ease of implementation of long mode
William> VHPT support.  The point of the above is that the virtual
William> placement constraint is an artifact of the implementation and
William> not inherent in hardware.

Ther's a patch available to enable long-format VHPT at
www.gelato.unsw.edu.au

We're waiting for 2.7 to open before pushing it in. The long-format
vpht is a prerequisite for other work we're doing on super-pagesand
TLB sharing.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
