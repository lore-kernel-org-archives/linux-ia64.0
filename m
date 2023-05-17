From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 17 May 2023 06:33:06 +0000
Subject: Re: [PATCH v5 RESEND 08/17] ia64: mm: Convert to GENERIC_IOREMAP
Message-Id: <ZGR1IlBpIDe6fQms@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230515090848.833045-1-bhe@redhat.com>
 <20230515090848.833045-9-bhe@redhat.com>
In-Reply-To: <20230515090848.833045-9-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, arnd@arndb.de, christophe.leroy@csgroup.eu, hch@infradead.org, agordeev@linux.ibm.com, wangkefeng.wang@huawei.com, schnelle@linux.ibm.com, David.Laight@aculab.com, shorne@gmail.com, willy@infradead.org, deller@gmx.de, linux-ia64@vger.kernel.org

> +#define ioremap_prot ioremap_prot
> +#define ioremap_cache ioremap
>  #define ioremap_uc ioremap_uc
>  #define iounmap iounmap

Same comment about the placement here, I'm not going to repeat it if
it shows up in more patches.

Otherwise looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
