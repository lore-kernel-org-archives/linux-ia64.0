From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 27 Feb 2004 07:44:38 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16446.62822.825187.768252@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Scott" = Scott Feldman <Feldman> writes:

>> Is this related to NAPI?
>> 
>> I'll assume "the gigabit" card is e1000: 

Nope, DP83820.  I'm benchmarking a driver that runs in userspace
against the in-kernel driver; both benefit from the interrupt speedup.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*

