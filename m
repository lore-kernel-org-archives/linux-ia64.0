From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 Sep 2005 20:37:46 +0000
Subject: RE: [patch 2.6.13 0/6] swiotlb maintenance and x86_64 dma_sync_single_range_for_{cpu,device}
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0475A8B6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104847.30871@bilbo.tuxdriver.com>
In-Reply-To: <09122005104847.30871@bilbo.tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org
Cc: ak@suse.de, "Mallick, Asit K" <asit.k.mallick@intel.com>

>Conduct some maintenance of the swiotlb code:
>
>	-- Move the code from arch/ia64/lib to lib

I agree that this code needs to move up out of arch/ia64, it is messy
that x86_64 needs to reach over and grab this from arch/ia64.

But is "lib" really the right place for it to move to?  Perhaps
a more logical place might be "drivers/pci/swiotlb/" since this
code is tightly coupled to pci?

-Tony
