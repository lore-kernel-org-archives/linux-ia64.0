From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Fri, 16 Dec 2016 06:49:23 +0000
Subject: Re: [PATCH v2 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <34293693-5424-9bdc-c693-dc385a5935e3@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148007477669.1053.4107773905913128028.stgit@hbathini.in.ibm.com>
 <148007484315.1053.12317233313990302812.stgit@hbathini.in.ibm.com>
 <20161201045653.GA13670@dhcp-128-65.nay.redhat.com>
 <fe3784de-a68b-5d6e-a9ab-f77a7da781a8@linux.vnet.ibm.com>
 <87mvge16gw.fsf@xmission.com>
In-Reply-To: <87mvge16gw.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Dave Young <dyoung@redhat.com>, vgoyal@redhat.com



On Saturday 03 December 2016 12:52 AM, Eric W. Biederman wrote:
> Hari Bathini <hbathini@linux.vnet.ibm.com> writes:
>
>> Hi Dave,
>>
>>
>> Thanks for the review.
>>
>>
>> On Thursday 01 December 2016 10:26 AM, Dave Young wrote:
>>> Hi Hari
>>>
>>> Personally I like V1 more, but split the patch 2 is easier for ia64
>>> people to reivew.  I did basic x86 testing, it runs ok.
>>>
>>> On 11/25/16 at 05:24pm, Hari Bathini wrote:
>>>> Get rid of multiple definitions of append_elf_note() & final_note()
>>>> functions. Reuse these functions compiled under CONFIG_CRASH_CORE.
>>>>
>>>> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
>>>> ---
>>>>    arch/ia64/kernel/crash.c   |   22 ----------------------
>>>>    include/linux/crash_core.h |    4 ++++
>>>>    kernel/crash_core.c        |    6 +++---
>>>>    kernel/kexec_core.c        |   28 ----------------------------
>>>>    4 files changed, 7 insertions(+), 53 deletions(-)
>>>>
>>>> diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
>>>> index 2955f35..75859a0 100644
>>>> --- a/arch/ia64/kernel/crash.c
>>>> +++ b/arch/ia64/kernel/crash.c
>>>> @@ -27,28 +27,6 @@ static int kdump_freeze_monarch;
>>>>    static int kdump_on_init = 1;
>>>>    static int kdump_on_fatal_mca = 1;
>>>>    -static inline Elf64_Word
>>>> -*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
>>>> -		size_t data_len)
>>>> -{
>>>> -	struct elf_note *note = (struct elf_note *)buf;
>>>> -	note->n_namesz = strlen(name) + 1;
>>>> -	note->n_descsz = data_len;
>>>> -	note->n_type   = type;
>>>> -	buf += (sizeof(*note) + 3)/4;
>>>> -	memcpy(buf, name, note->n_namesz);
>>>> -	buf += (note->n_namesz + 3)/4;
>>>> -	memcpy(buf, data, data_len);
>>>> -	buf += (data_len + 3)/4;
>>>> -	return buf;
>>>> -}
>>>> -
>>>> -static void
>>>> -final_note(void *buf)
>>>> -{
>>>> -	memset(buf, 0, sizeof(struct elf_note));
>>>> -}
>>>> -
>>> The above IA64 version looks better than the functions in kexec_core.c
>>> about the Elf64_Word type usage and the simpler final_note function.
>> Hmmm.. Is void* better over Elf64_Word* to be agnostic of Elf32 or
>> Elf64 type?
> Both Elf64_Word and Elf32_Word result in a u32.  So I expect the right
> solution is to add a definition of Elf_Word to include/linux/elf.h
> and to make the buffer "Elf_Word *buf".
>
> That way we preserve the alignment knowledge, while making the code
> depend on 32bit or 64bit.
>
> Eric
>

Thanks for the review, Eric. Will address this in the next version.

As some recent changes in powerpc tree may cause merger conflicts,
I will wait for those changes to get into linus's tree and rebase the
next version on top of that..

Thanks
Hari

