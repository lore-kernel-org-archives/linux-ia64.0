From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 28 May 2003 02:37:32 +0000
Subject: [Linux-ia64] Long format VHPT and TLB sharing patches
Message-Id: <marc-linux-ia64-105590723706052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As part of research we did at UNSW, we implemented the long format VHPT
as well as some experimental features to improve TLB coverage (sharing
of RIDs for text regions, and a global shared mmap region with protection
keys for protection).  We are now making these patches available.

The long format VHPT patch should be fairly stable.  It could be used
as a basis for future work on superpages etc.

The sharing patches are experimental, and were intended to evaluate the
performance effects of such changes.  They are not ready for "prime
time".

All of the relevant information is at:

http://www.gelato.unsw.edu.au/sharedtlb/

Thanks in particular to Ian Wienand for his excellent help in testing,
benchmarking, and preparing the above page.

Matt


