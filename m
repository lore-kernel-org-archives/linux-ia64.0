From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 May 2004 13:23:27 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F012F28FC@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>, Sourav Sen <souravs@india.hp.com>
Cc: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>2) Can the memory map output ever be larger than PAGE_SIZE (lower
>limit is 4KB on x86)?  If not, what guarantees that?  If so, you need
>your own read mechanism rather than the generic sysfs one.

The output format of the sprintf() gives 58 characters per entry, which
with a 4k page allows for 70 entries before the page overflows, which
feels borderline for ccNUMA machines.  On ia64 the pagesize is usually
16k, which would allow 282 entries.  I think this will fail on a 128
node SGI sn2 (because there are 4 memory banks per node => min 512
entries
in the memory map).

-Tony
