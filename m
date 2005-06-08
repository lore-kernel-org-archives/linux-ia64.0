From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Jun 2005 17:11:05 +0000
Subject: RE: gate page oops
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03A58929@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Unless there are any objections, please apply (for 2.6.12, hopefully).

I still don't really understand why there are still any "PERCPU_PAGE_SIZE"
references in this code.

It looks like if we are building with a buggy linker, then we workaround
problems by having two separate pages in our vmlinux image, and we map
them at consecutive virtual pages (of size PAGE_SIZE) at the start of region
5 (GATE_ADDR = 0xa000000000000000).

With a good linker, there is only one page in the vmlinux image, and we map
it twice ... but for some unspecified reason we put the mappings on
PERCPU_PAGE_SIZE boundaries at the start of region 5.  This leaves two holes
(assuming PERCPU_PAGE_SIZE > PAGE_SIZE ... which it is unless PAGE_SIZEdk).

Why do we need the holes?

Should we also map zero pages in the buggy linker case (since there is a hole
from GATE_ADDR + 2*PAGE_SIZE to FIXADDR_USER_END where there are no mappings).
Or perhaps FIXADDR_USER_END should only be GATE_ADDR + 2*PAGE_SIZE in the
buggy linker case?

-Tony
