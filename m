From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Oct 2004 06:33:28 +0000
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : intro[0/2]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221CC82@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41638EC8.9090901@jp.fujitsu.com>
In-Reply-To: <41638EC8.9090901@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

>ia64's ia64_pfn_valid() uses get_user() for checking whether a 
>page struct is available or not. I think this is an irregular 
>implementation and following patches
>are a more generic replacement, careful_pfn_valid(). It uses 2 
>level table.

It is odd ... but a somewhat convenient way to make check whether
the page struct exists, while handling the fault if it is in an
area of virtual mem_map that doesn't exist.  I think that in practice
we rarely call it with a pfn that generates a fault (except in error
paths).

How big will the pfn_validmap[] be for a very sparse physical space
like SGI Altix?  I'm not sure I see how PFN_VALID_MAPSHIFT is 
generated for each system.

Why do we need a loop when looking in the 2nd level?  Can't the
entry from the 1st level point us to the right place?

-Tony
