From: Michal Hocko <mhocko@suse.com>
Date: Fri, 07 May 2021 11:55:24 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <YJUqrOacyqI+kiKW@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
In-Reply-To: <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>, David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

[I haven't read through respective patches due to lack of time but let
 me comment on the general idea and the underlying justification]

On Thu 06-05-21 17:31:09, David Hildenbrand wrote:
> On 06.05.21 17:26, Zi Yan wrote:
> > From: Zi Yan <ziy@nvidia.com>
> > 
> > Hi all,
> > 
> > This patchset tries to remove the restriction on memory hotplug/hotremove
> > granularity, which is always greater or equal to memory section size[1].
> > With the patchset, kernel is able to online/offline memory at a size independent
> > of memory section size, as small as 2MB (the subsection size).
> 
> ... which doesn't make any sense as we can only online/offline whole memory
> block devices.

Agreed. The subsection thingy is just a hack to workaround pmem
alignement problems. For the real memory hotplug it is quite hard to
argue for reasonable hotplug scenarios for very small physical memory
ranges wrt. to the existing sparsemem memory model.
 
> > The motivation is to increase MAX_ORDER of the buddy allocator and pageblock
> > size without increasing memory hotplug/hotremove granularity at the same time,
> 
> Gah, no. Please no. No.

Agreed. Those are completely independent concepts. MAX_ORDER is can be
really arbitrary irrespective of the section size with vmemmap sparse
model. The existing restriction is due to old sparse model not being
able to do page pointer arithmetic across memory sections. Is there any
reason to stick with that memory model for an advance feature you are
working on?
-- 
Michal Hocko
SUSE Labs
