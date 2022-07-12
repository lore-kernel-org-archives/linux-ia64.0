From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 12 Jul 2022 02:51:53 +0000
Subject: Re: [PATCH V7 00/26] mm/mmap: Drop __SXXX/__PXXX macros from across platforms
Message-Id: <48ab9e36-48be-916e-2ce7-03ef59d67dae@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220711070600.2378316-1-anshuman.khandual@arm.com>
 <20220711131417.9cac57d9b88eea8bbd7d8616@linux-foundation.org>
In-Reply-To: <20220711131417.9cac57d9b88eea8bbd7d8616@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hch@infradead.org, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, x86@kernel.org, openrisc@lists.librecores.org, linux-xtensa@linux-xtensa.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-m68k@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-um@lists.infradead.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org



On 7/12/22 01:44, Andrew Morton wrote:
> On Mon, 11 Jul 2022 12:35:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> This series drops __SXXX/__PXXX macros from across platforms in the tree.
> 
> I've updated mm-unstable to this version, thanks.  I skipped the added-to-mm
> emails to avoid wearing out people's inboxes.
> 
> Reissuing a 26-patch series N times is rather noisy.  Please prefer to send incremental
> fixes when changes are minor.  It makes it so much easier for reviewers to see what
> happened.

Sure, got it, will follow next time.
