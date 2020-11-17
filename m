From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 17 Nov 2020 05:24:51 +0000
Subject: Re: [PATCH v2 00/13] arch, mm: deprecate DISCONTIGMEM
Message-Id: <43c53597-6267-bdc2-a975-0aab5daa0d37@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201101170454.9567-1-rppt@kernel.org>
In-Reply-To: <20201101170454.9567-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Michael Schmitz <schmitzmic@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-snps-arc@lists.infradead.org

Hi!

On 11/1/20 6:04 PM, Mike Rapoport wrote:
> It's been a while since DISCONTIGMEM is generally considered deprecated,
> but it is still used by four architectures. This set replaces DISCONTIGMEM
> with a different way to handle holes in the memory map and marks
> DISCONTIGMEM configuration as BROKEN in Kconfigs of these architectures with
> the intention to completely remove it in several releases.
> 
> While for 64-bit alpha and ia64 the switch to SPARSEMEM is quite obvious
> and was a matter of moving some bits around, for smaller 32-bit arc and
> m68k SPARSEMEM is not necessarily the best thing to do.
> 
> On 32-bit machines SPARSEMEM would require large sections to make section
> index fit in the page flags, but larger sections mean that more memory is
> wasted for unused memory map.
> 
> Besides, pfn_to_page() and page_to_pfn() become less efficient, at least on
> arc.
> 
> So I've decided to generalize arm's approach for freeing of unused parts of
> the memory map with FLATMEM and enable it for both arc and m68k. The
> details are in the description of patches 10 (arc) and 13 (m68k).

Apologies for the late reply. Is this still relevant for testing?

I have already successfully tested v1 of the patch set, shall I test v2?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
