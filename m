From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 09 Jul 2004 05:24:35 +0000
Subject: Reading L1D cache tags
Message-Id: <20040709052435.GA11435@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I don't expect a response to this, given the general climate of secrecy
and NDAs surrounding processor implementations, but I might as well give
it a try.

Does anyone know how to read the (one-hot) tags out of the L1D cache on
Itanium 2?

I can do this for the L1I cache (mostly thanks to info in PAL).  I'm
currently using this to visualize the contents of the L1I at a
particular point in time, like this (shortly after a TLB flush...  you
can see the VHPT miss handler at the bottom):

1b V 4000000000005000 0004077e05000            *****                                                
1c V 4000000000004000 0004077e04000              *****                                              
1d V 400000000000c000 00040452b8000 ********                                                        
1e V 4000000000006000 0004077e06000                              *****************                  
1f V a000000100000000 0000004000000 **********                                                      

where the L1ITLB entries are on the left, and on the right each column
represents a cache line within the page, '*' indicates that it is
present within L1I.

I'm more interested in doing this for L1D though, which I can't figure
out how to do.  I'm guessing it should be possible though... it's a bit
pointless being able to inspect the L1D data if you can't read the tags,
since you don't know which way is which.

Anyone else looked at such things?

Matt

