From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 09 Aug 2004 19:12:49 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040809191249.GT11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040806210750.GT17188@holomorphy.com> <200408091819.i79IJ3Y12216@unix-os.sc.intel.com>
In-Reply-To: <200408091819.i79IJ3Y12216@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hirokazu Takahashi' <taka@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

William Lee Irwin III wrote on Friday, August 06, 2004 2:08 PM
>> update_mmu_cache() does not appear to check the size of the translation
>> to be established in many architectures. e.g. on arch/ia64/ it does
>> flush_icache_range(addr, addr + PAGE_SIZE) unconditionally, and only
>> sets PG_arch_1 on a single struct page. Similar comments apply to
>> sparc64 and ppc64; I didn't check any others.

On Mon, Aug 09, 2004 at 11:19:04AM -0700, Chen, Kenneth W wrote:
> I suppose this is fixable in update_mmu_cache() where it can check the
> type of pte and do appropriate sizing and other things.  ia64 would have
> to check the address instead of looking at the pte.

Yes, it's just a fair amount of document-hunting since there isn't
always easily cut-and-pasteable stuff (e.g. ITAG_MASK for larger page
sizes was omitted from the #ifdefs on sparc64).

As for ia64 checking addresses... ew, can't we just use long format
VHPT? The virtual placement constraints are nasty.


-- wli
