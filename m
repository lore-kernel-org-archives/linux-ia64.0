From: David Hildenbrand <david@redhat.com>
Date: Wed, 05 Feb 2020 13:23:14 +0000
Subject: Re: [PATCH v6 10/10] mm/memory_hotplug: Cleanup __remove_pages()
Message-Id: <9c6a3d3a-06de-2474-4147-82ab9ba446ed@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191006085646.5768-1-david@redhat.com>
 <20191006085646.5768-11-david@redhat.com> <20200204094652.GE6494@linux>
 <5d698f94-af18-0714-bc97-14b6c520572c@redhat.com>
 <20200204131353.GJ22482@gate.crashing.org>
 <0e2f700c-b01b-8c16-99c2-2648967fc203@redhat.com>
 <20200205125149.GS22482@gate.crashing.org>
 <32e06c13-222c-4486-3914-df2807cf2a2b@redhat.com>
 <8f4752f5-c676-f56e-8cd2-239898aba2fd@redhat.com>
In-Reply-To: <8f4752f5-c676-f56e-8cd2-239898aba2fd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: linux-s390@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richardw.yang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>

On 05.02.20 14:18, David Hildenbrand wrote:
>> I'm sorry to have to correct you again for some corner cases:
>>
>> ALIGN_UP(1, 4096) - 4096 = 0
>>
>> Again, not as easy as it seems ...
>>
> 
> Eh, wait, I'm messing up things. Will double check :)
> 

Yes, makes sense, will send a patch and cc you. Thanks!

-- 
Thanks,

David / dhildenb
