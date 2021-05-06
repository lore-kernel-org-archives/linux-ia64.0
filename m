From: David Hildenbrand <david@redhat.com>
Date: Thu, 06 May 2021 15:40:15 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <3a51f564-f3d1-c21f-93b5-1b91639523ec@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
In-Reply-To: <9D7FD316-988E-4B11-AC1C-64FF790BA79E@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

>>> The last patch increases SECTION_SIZE_BITS to demonstrate the use of memory
>>> hotplug/hotremove subsection, but is not intended to be merged as is. It is
>>> there in case one wants to try this out and will be removed during the final
>>> submission.
>>>
>>> Feel free to give suggestions and comments. I am looking forward to your
>>> feedback.
>>
>> Please not like this.
> 
> Do you mind sharing more useful feedback instead of just saying a lot of No?

I remember reasoning about this already in another thread, no? Either 
you're ignoring my previous feedback or my mind is messing with me.

-- 
Thanks,

David / dhildenb
