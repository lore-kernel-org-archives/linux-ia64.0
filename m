From: Jessica Clarke <jrtc27@jrtc27.com>
Date: Thu, 13 Aug 2020 21:44:58 +0000
Subject: Re: [PATCH v5] arch/ia64: Restore arch-specific pgd_offset_k implementation
Message-Id: <F4600526-D387-4147-A1BA-435FCA2C6618@jrtc27.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200813205521.5405-1-rppt@kernel.org>
 <20200813213631.GQ17456@casper.infradead.org>
In-Reply-To: <20200813213631.GQ17456@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, Linux MM <linux-mm@kvack.org>, Frank Scheiner <frank.scheiner@web.de>, Mike Rapoport <rppt@linux.ibm.com>

On 13 Aug 2020, at 22:36, Matthew Wilcox <willy@infradead.org> wrote:
> 
> On Thu, Aug 13, 2020 at 11:55:21PM +0300, Mike Rapoport wrote:
>> +/*
>> + * In the kernel's mapped region we know everything is in region number 5, so
>> + * as an optimisation its PGD already points to the area for that region.
> 
> Is it actually an optimisation?  Are there any benchmarks where this
> makes any difference whatsoever?  Or should the comment be closer to
> 
> /* ia64 is gratuitously different.  Cope with it. */
> 
> I might suggest that pgd be changed to be the same as every other pgd
> in the system, and every other architecture.

IA-64 is just weird. There's an optional hardware page table walker,
and two different options for how to use it within that, short-format
and long-format. My understanding is that Linux uses the short-format,
and that means that the VHPTs (Virtual Hashed Page Table) are
per-region. My assumption therefore is that the kernel's PGD is a
completely separate allocation from the userspace ones, and it's not
just a case of "moving the pointer back to the start" but that "that is
all there is", so unifying the two would be a significant undertaking
that avoids one special case at the cost of invasive refactoring and a
performance hit by duplication and/or unused space. My knowledge of
IA-64 translation is pretty limited, that's about all I know (and this
likely has mistakes in it), but I know enough to avoid finding out too
much more. Never make the mistake of assuming IA-64 can be made to look
like any other architecture :)

Jess
