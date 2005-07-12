From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 12 Jul 2005 17:14:36 +0000
Subject: RE: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03E3D3F7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is better.  But allowing access to region 6 through
/dev/kmem will open up a whole new set of problems.  If the
user does an uncacheable read through region 6 from a memory
address that is mapped cacheably in region 7, then the
processor may machine check [SDM 4.4.1, page 2:64, last
paragraph: "It is recommended that the processor report a
Machine Check abort if the following memory attribute aliasing
is detected: * cache-hit on an uncacheable page"]

So I think we should disallow access to region 6.

-Tony
