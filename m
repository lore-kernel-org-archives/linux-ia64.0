From: Baoquan He <bhe@redhat.com>
Date: Sun, 28 Aug 2022 15:12:38 +0000
Subject: Re: [PATCH v2 06/11] ia64: mm: Convert to GENERIC_IOREMAP
Message-Id: <YwuF5oobjhahuybe@MiWiFi-R3L-srv>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220820003125.353570-1-bhe@redhat.com>
 <20220820003125.353570-7-bhe@redhat.com>
 <YwHYeiBP4EKi1Hd8@infradead.org>
In-Reply-To: <YwHYeiBP4EKi1Hd8@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, agordeev@linux.ibm.com, wangkefeng.wang@huawei.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org

On 08/21/22 at 12:02am, Christoph Hellwig wrote:
> On Sat, Aug 20, 2022 at 08:31:20AM +0800, Baoquan He wrote:
> > Add hooks arch_ioremap() and arch_iounmap() for ia64's special
> > operation when ioremap() and iounmap(), then ioremap_cache() is
> > converted to use ioremap_prot() from GENERIC_IOREMAP.
> 
> Same comment about the commit log (I won't repeat it as it applies
> to all conversions).

Will do.
