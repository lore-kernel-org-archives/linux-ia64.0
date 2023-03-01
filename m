From: David Hildenbrand <david@redhat.com>
Date: Wed, 01 Mar 2023 08:16:06 +0000
Subject: Re: [PATCH v7 13/41] mm: Make pte_mkwrite() take a VMA
Message-Id: <550c6035-6dd0-d215-226b-1a82dafa05d6@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230227222957.24501-1-rick.p.edgecombe@intel.com>
 <20230227222957.24501-14-rick.p.edgecombe@intel.com>
 <1f8b78b6-9f34-b646-68f2-eac62136b9f4@csgroup.eu>
In-Reply-To: <1f8b78b6-9f34-b646-68f2-eac62136b9f4@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Rick Edgecombe <rick.p.edgecombe@intel.com>, "x86@kernel.org" <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H . J . Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Weijiang Yang <weijiang.yang@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Allen <john.allen@amd.com>, "kcc@google.com" <kcc@google.com>, "eranian@google.com" <eranian@google.com>, "rppt@kernel.org" <rppt@kernel.org>, "jamorris@linux.microsoft.com" <jamorris@linux.microsoft.com>, "dethoma@microsoft.com" <dethoma@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Andrew.Cooper3@citrix.com" <Andrew.Cooper3@citrix.com>, "christina.schimpe@intel.com" <christina.schimpe@intel.com>, "debug@rivosinc.com" <debug@rivosinc.com>
Cc: "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linux-openrisc@vger.kernel.org" <linux-openrisc@vger.kernel.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>

On 01.03.23 08:03, Christophe Leroy wrote:
> 
> 
> Le 27/02/2023 à 23:29, Rick Edgecombe a écrit :
>> The x86 Control-flow Enforcement Technology (CET) feature includes a new
>> type of memory called shadow stack. This shadow stack memory has some
>> unusual properties, which requires some core mm changes to function
>> properly.
>>
>> One of these unusual properties is that shadow stack memory is writable,
>> but only in limited ways. These limits are applied via a specific PTE
>> bit combination. Nevertheless, the memory is writable, and core mm code
>> will need to apply the writable permissions in the typical paths that
>> call pte_mkwrite().
>>
>> In addition to VM_WRITE, the shadow stack VMA's will have a flag denoting
>> that they are special shadow stack flavor of writable memory. So make
>> pte_mkwrite() take a VMA, so that the x86 implementation of it can know to
>> create regular writable memory or shadow stack memory.
>>
>> Apply the same changes for pmd_mkwrite() and huge_pte_mkwrite().
> 
> I'm not sure it is a good idea to add a second argument to
> pte_mkwrite(). All pte_mkxxxx() only take a pte and nothing else.

We touched on this in previous revisions and so far there was no strong 
push back. This turned out to be cleaner and easier than the 
alternatives we evaluated.

pte_modify(), for example, takes another argument. Sure, we could try 
thinking about passing something else than a VMA to identify the 
writability type, but I am not convinced that will look particularly better.

> 
> I think you should do the same as commit d9ed9faac283 ("mm: add new
> arch_make_huge_pte() method for tile support")
> 

We already have 3 architectures intending to support shadow stacks in 
one way or the other. Replacing all pte_mkwrite() with 
arch_pte_mkwrite() doesn't sound particularly appealing to me.


-- 
Thanks,

David / dhildenb
