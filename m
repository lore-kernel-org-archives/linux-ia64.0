From: David Miller <davem@davemloft.net>
Date: Wed, 30 Aug 2006 22:27:05 +0000
Subject: Re: [RFC][PATCH 5/9] sparc64 generic PAGE_SIZE
Message-Id: <20060830.152705.27955313.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	<20060830221608.A33491C8@localhost.localdomain>
In-Reply-To: <20060830221608.A33491C8@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: haveblue@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 30 Aug 2006 15:16:08 -0700

> 
> This is the sparc64 portion to convert it over to the generic PAGE_SIZE
> framework.
> 
> * Change all references to CONFIG_SPARC64_PAGE_SIZE_*KB to
>   CONFIG_PAGE_SIZE_* and update the defconfig.
> * remove sparc64-specific Kconfig menu
> * add sparc64 default of 8k pages to mm/Kconfig
> * remove generic support for 4k pages
> * add support for 8k, 64k, 512k, and 4MB pages
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

Signed-off-by: David S. Miller <davem@davemloft.net>
