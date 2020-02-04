From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Tue, 04 Feb 2020 13:13:53 +0000
Subject: Re: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <20200204131353.GJ22482@gate.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-11-david@redhat.com> <20200204094652.GE6494@linux>
 <5d698f94-af18-0714-bc97-14b6c520572c@redhat.com>
In-Reply-To: <5d698f94-af18-0714-bc97-14b6c520572c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On Tue, Feb 04, 2020 at 01:41:06PM +0100, David Hildenbrand wrote:
> On 04.02.20 10:46, Oscar Salvador wrote:
> > I have to confess that it took me while to wrap around my head
> > with the new min() change, but looks ok:
> 
> It's a pattern commonly used in compilers and emulators to calculate the
> number of bytes to the next block/alignment. (we're missing a macro
> (like we have ALIGN_UP/IS_ALIGNED) for that - but it's hard to come up
> with a good name (e.g., SIZE_TO_NEXT_ALIGN) .

You can just write the easy to understand

  ...  ALIGN_UP(x) - x  ...

which is better *without* having a separate name.  Does that not
generate good machine code for you?


Segher
