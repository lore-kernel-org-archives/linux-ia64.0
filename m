From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Aug 2005 18:03:35 +0000
Subject: RE: [patch 2.6.13] swiotlb: add swiotlb_sync_single_range_for_{cpu,device}
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0443A4B5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050830175803.GC18998@tuxdriver.com>
In-Reply-To: <20050830175803.GC18998@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, linux-ia64@vger.kernel.org


>+swiotlb_sync_single_range_for_cpu(struct device *hwdev, 
>+swiotlb_sync_single_range_for_device(struct device *hwdev, 

Huh?  These look identical ... same args, same code, just a
different name.

-Tony
