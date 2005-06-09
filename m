From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Jun 2005 17:48:56 +0000
Subject: RE: gate page oops
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03A9780F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Tony> Why do we need the holes?
>
>Because ia64 linux ELF images can only alias at a 64KB boundary (the
>max. supported kernel page size).

This means that PERCPU_PAGE_SIZE is the wrong define for this.  It
happens to have the value 64K today, but it is only a coincidence that
this is the maximum kernel page size.

In fact, we are already using more than half of the per cpu page (not
counting any modules that allocate per cpu space):

  $ grep __per_cpu_end System.map
  ffffffffffff8588 D __per_cpu_end

so at some point we may need to increase it to 256K (next supported TLB
page size).  Your code will still work, but we'll be filling in much bigger
holes than we need.

-Tony
