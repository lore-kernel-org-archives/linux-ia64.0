From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Dec 2004 18:07:02 +0000
Subject: RE: virtual memmap and page_address
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F029006BD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412150953.32812.jbarnes@engr.sgi.com>
In-Reply-To: <200412150953.32812.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>When virtual memmaps are enabled, page_address will return a region 5 
>pointer.

Are you sure?  It looks to me that without WANT_PAGE_VIRTUAL that
we end up in lowmem_page_address(), which just gives us:

  __va(page_to_pfn(page) << PAGE_SHIFT)

which has got to be a region 7 address.

What's the code path that you are looking at that can return a
region 5 address?

-Tony
