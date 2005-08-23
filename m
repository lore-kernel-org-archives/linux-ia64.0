From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Aug 2005 16:24:53 +0000
Subject: RE: Large-page support
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0434AE9C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <007d01c5a7e8$b1103d90$33d84c0f@asiapacific.hpqcorp.net>
In-Reply-To: <007d01c5a7e8$b1103d90$33d84c0f@asiapacific.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What is the current level of large page support implemented
>for Linux ?

Linux currently doesn't support "large" pages ... but it does support
"huge" ones.

On ia64 there is a kernel compile-time choice for the regular page size
between 4k, 8k, 16k and 64k.  The default is 16k.

Huge page size is selectable via a boot-time parameter "hugepagesz=",
choices are just about anything supported by h/w (current implementations
of Itanium 2 support even powers of two up to 4G). Default is 256MB.

>Can applications specify a certain page-size to use for
>their private mappings ? Is this limited to any particular page-size ?

No ... normal allocations are done using the default system page
size.  To see how to use huge pages, read Documentation/vm/hugetlbpage.txt
in the Linux kernel sources.

>Is smart-demotion implemented ?
No.

-Tony
