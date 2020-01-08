From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 08 Jan 2020 19:29:00 +0000
Subject: Re: [PATCH v2 2/8] mm/memory_hotplug: Rename mhp_restrictions to mhp_modifiers
Message-Id: <1786a855-de7e-f9f9-d9b1-9dbe081e7360@deltatee.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAPcyv4hdpMs5om4_VrYUz98aWDJ9eRhj7WJr312Jwn6LCmAm9Q@mail.gmail.com>
 <5D5ED235-EB67-4072-8CCA-C046B7EC031C@redhat.com>
 <CAPcyv4jJgBm6rhLn2685HN3DnBKB1FO2ONXC1=Aftspu1hiqmA@mail.gmail.com>
In-Reply-To: <CAPcyv4jJgBm6rhLn2685HN3DnBKB1FO2ONXC1=Aftspu1hiqmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>
Cc: linux-s390 <linux-s390@vger.kernel.org>, Eric Badger <ebadger@gigaio.com>, linux-ia64@vger.kernel.org, Will Deacon <will@kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, platform-driver-x86@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Christoph Hellwig <hch@lst.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>



On 2020-01-08 12:13 p.m., Dan Williams wrote:
> On Wed, Jan 8, 2020 at 11:08 AM David Hildenbrand <david@redhat.com> wrote:
>>
>>
>>
>>> Am 08.01.2020 um 20:00 schrieb Dan Williams <dan.j.williams@intel.com>:
>>>
>>> ﻿On Wed, Jan 8, 2020 at 9:17 AM Logan Gunthorpe <logang@deltatee.com> wrote:
>>>>
>>>>
>>>>
>>>>> On 2020-01-08 5:28 a.m., David Hildenbrand wrote:
>>>>> On 07.01.20 21:59, Logan Gunthorpe wrote:
>>>>>> The mhp_restrictions struct really doesn't specify anything resembling
>>>>>> a restriction anymore so rename it to be mhp_modifiers.
>>>>>
>>>>> I wonder if something like "mhp_params" would be even better. It's
>>>>> essentially just a way to avoid changing call chains rough-out all archs
>>>>> whenever we want to add a new parameter.
>>>>
>>>> Sure, that does sound a bit nicer to me. I can change it for v3.
>>>
>>> Oh, I was just about to chime in to support "modifiers" because I
>>> would expect all parameters to folded into a "params" struct. The
>>> modifiers seem to be limited to the set of items that are only
>>> considered in a non-default / expert memory hotplug use cases.

>>
>> It‘s a set of extended parameters I‘d say.

> Sure, we can call them "mhp_params" and just clarify that they are
> optional / extended in the kernel-doc.

Well pgprot isn't going to be optional... But I'll add something to the
kernel_doc.

Logan
