From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 06 May 2004 16:14:03 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEB18@fmsmsx406.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>, Sourav Sen <souravs@india.hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> 2) Can the memory map output ever be larger than PAGE_SIZE (lower
> limit is 4KB on x86)?  If not, what guarantees that?  If so, you need
> your own read mechanism rather than the generic sysfs one.

There are no size guarantees with the EFI memory map.  It could
be of various sizes...

matt

