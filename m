From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 22 Aug 2007 21:04:22 +0000
Subject: RE: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted
Message-Id: <617E1C2C70743745A92448908E030B2A023B2D39@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46CC48FD.4000607@linux.vnet.ibm.com> <20070822091959.aa38fd3e.akpm@linux-foundation.org> <20070822172541.GA8058@bingen.suse.de> <46CC811C.9010600@linux.vnet.ibm.com>
In-Reply-To: <46CC811C.9010600@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org

> Attached the boot log and config file.

Kamelesh,

I don't see anything obvious in the boot_log.

I used your "dotconfig" file to build a 2.6.23-rc3-mm1 kernel
and booted it on my test system ... it worked just fine
(except that for some reason the network did not come up :-( )

I tried to compare my boot log with yours ... you have some
different devices (E.g. your ethernet links are Tigon3 while
mine are e1000) ... so the memory leak in a driver theory
is a possibility.

Try adding a dump_stack() call to lib/swiotlb.c where the
"DMA: Out of SW-IOMMU space ..." message is printed.  That
would tell us who is making the call that fails (they
might be an innocent bystander after someone else has
used all the space ... but this is unlikely).

-Ton
