From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Oct 2004 15:53:32 +0000
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F022668D0@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41638EC8.9090901@jp.fujitsu.com>
In-Reply-To: <41638EC8.9090901@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

>The normal way to fix the above is just to have a bitmap array 
>to test - in your case a 1GB granularity would be sufficicent. That 
>takes < 1 word to implement for the example above ;-)

In the general case you need a bit for each granule (since that is the
unit that the kernel admits/denies the existence of memory).  But the
really sparse systems end up with a large bitmap.  SGI Altix uses 49
physical address bits, and a granule size of 16MB ... so we need 2^25
bits ... i.e. 4MBbytes.  While that's a drop in the ocean on a 4TB
machine, it still seems a pointless waste.

-Tony
