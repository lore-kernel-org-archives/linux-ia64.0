From: Baoquan He <bhe@redhat.com>
Date: Thu, 18 May 2023 03:44:32 +0000
Subject: Re: [PATCH v5 RESEND 08/17] ia64: mm: Convert to GENERIC_IOREMAP
Message-Id: <ZGWfIIi2aH8SMTfZ@MiWiFi-R3L-srv>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230515090848.833045-1-bhe@redhat.com>
 <20230515090848.833045-9-bhe@redhat.com>
 <ZGR1IlBpIDe6fQms@infradead.org>
In-Reply-To: <ZGR1IlBpIDe6fQms@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, arnd@arndb.de, christophe.leroy@csgroup.eu, agordeev@linux.ibm.com, wangkefeng.wang@huawei.com, schnelle@linux.ibm.com, David.Laight@aculab.com, shorne@gmail.com, willy@infradead.org, deller@gmx.de, linux-ia64@vger.kernel.org

On 05/16/23 at 11:33pm, Christoph Hellwig wrote:
> > +#define ioremap_prot ioremap_prot
> > +#define ioremap_cache ioremap
> >  #define ioremap_uc ioremap_uc
> >  #define iounmap iounmap
> 
> Same comment about the placement here, I'm not going to repeat it if
> it shows up in more patches.

Sure, Will check all of them and change, thanks.

> 
> Otherwise looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
