From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Fri, 24 Jun 2022 06:21:46 +0000
Subject: Re: [PATCH V4 02/26] mm/mmap: Define DECLARE_VM_GET_PAGE_PROT
Message-Id: <4a20d826-af0f-0d2c-162e-8797c2603ab1@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220624044339.1533882-1-anshuman.khandual@arm.com>
 <20220624044339.1533882-3-anshuman.khandual@arm.com>
 <YrVHEw6bjUf62Eh5@infradead.org>
In-Reply-To: <YrVHEw6bjUf62Eh5@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, christophe.leroy@csgroup.eu, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org



On 6/24/22 10:39, Christoph Hellwig wrote:
> On Fri, Jun 24, 2022 at 10:13:15AM +0530, Anshuman Khandual wrote:
>> This just converts the generic vm_get_page_prot() implementation into a new
>> macro i.e DECLARE_VM_GET_PAGE_PROT which later can be used across platforms
>> when enabling them with ARCH_HAS_VM_GET_PAGE_PROT. This does not create any
>> functional change.
> 
> mm.h is a huhe header included by almost everything in the kernel.
> I'd rather have it in something only included in a few files.  If we
> can't find anything suitable it might be worth to add a header just
> for this even.

I guess <linux/pgtable.h> should be better ?
