From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 24 Aug 2005 03:22:33 +0000
Subject: Re: Nasty VMLPT problem...
Message-Id: <17163.59385.243864.934098@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
In-Reply-To: <17163.58446.637451.839535@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

Peter> Hi Folks, I've solved the problem I was having with the
Peter> simulator and not booting Debian.

Peter> The problem is that the number of bits for the virtual linear
Peter> array short-format VHPT (Virtually mapped linear page table,
Peter> VMLPT for short) is being calculated incorrectly.
				 s/calculated/tested/

Sorry.
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
