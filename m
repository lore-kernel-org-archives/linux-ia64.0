From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Oct 2004 05:22:20 +0000
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41638EC8.9090901@jp.fujitsu.com>
In-Reply-To: <41638EC8.9090901@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

>Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
>I want to avoid page fault caused by using get_user() in pfn_valid().

How often?  Surely this is only a problem at the edges of blocks
of memory?  I suppose it depends on whether your discontig memory
appears in blocks much smaller than MAXORDER.  But even there it
should only be an issue coalescing buddies that are bigger than
the granule size (since all of the pages in a granule on ia64 are
guaranteed to exist, the buddy of any page must also exist).

Do you have some data to show that this is a problem.

-Tony
