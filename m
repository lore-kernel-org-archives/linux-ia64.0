From: "Arnd Bergmann" <arnd@arndb.de>
Date: Mon, 12 Sep 2022 13:53:54 +0000
Subject: Re: [PATCH] ia64: export memory_add_physaddr_to_nid to fix cxl build error
Message-Id: <687a977d-81a4-497e-86ba-b63ff4cad518@www.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220911012616.29948-1-rdunlap@infradead.org>
In-Reply-To: <20220911012616.29948-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org
Cc: kernel test robot <lkp@intel.com>, Dan Williams <dan.j.williams@intel.com>, Ben Widawsky <bwidawsk@kernel.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-ia64@vger.kernel.org, Keith Mannthey <kmannth@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 11, 2022, at 3:26 AM, Randy Dunlap wrote:
> cxl_pmem.ko uses memory_add_physaddr_to_nid() but ia64 does not export it,
> so this causes a build error:
>
> ERROR: modpost: "memory_add_physaddr_to_nid" [drivers/cxl/cxl_pmem.ko] 
> undefined!
>
> Fix this by exporting that function.
>
> Fixes: 8c2676a5870a ("hot-add-mem x86_64: memory_add_physaddr_to_nid 
> node fixup")
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ben Widawsky <bwidawsk@kernel.org>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Keith Mannthey <kmannth@us.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Arnd, can you take this in your one-off fixes arch tree, or would
> you prefer for Andrew to take it?

I've applied it to the asm-generic tree for 6.1 now, as I don't
expect any other bugfixes for 6.0 to go through that tree. It's
clearly a bugfix, but since the original commit you cite was from
2006, I assume it can wait a little longer.

     Arnd
