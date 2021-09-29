From: David Hildenbrand <david@redhat.com>
Date: Wed, 29 Sep 2021 16:30:09 +0000
Subject: Re: [PATCH v1 2/4] memblock: allow to specify flags with memblock_add_node()
Message-Id: <3651c7d0-f7b6-63ff-216a-b74176623a6f@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210927150518.8607-1-david@redhat.com>
 <20210927150518.8607-3-david@redhat.com> <YVSTkGdh2nQWQp+U@kernel.org>
In-Reply-To: <YVSTkGdh2nQWQp+U@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On 29.09.21 18:25, Mike Rapoport wrote:
> On Mon, Sep 27, 2021 at 05:05:16PM +0200, David Hildenbrand wrote:
>> We want to specify flags when hotplugging memory. Let's prepare to pass
>> flags to memblock_add_node() by adjusting all existing users.
>>
>> Note that when hotplugging memory the system is already up and running
>> and we don't want to add the memory first and apply flags later: it
>> should happen within one memblock call.
> 
> Why is it important that the system is up and why it should happen in a
> single call?
> I don't mind adding flags parameter to memblock_add_node() but this
> changelog does not really explain the reasons to do it.

"After memblock_add_node(), we could race with anybody performing a 
search for MEMBLOCK_NONE, like kexec_file -- and that only happens once 
the system is already up and running. So we want both steps to happen 
atomically."

I can add that to the patch description.

(I think it still won't be completely atomic because memblock isn't 
properly implementing locking yet, but that's a different story)

-- 
Thanks,

David / dhildenb
