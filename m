From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Tue, 24 Jan 2017 18:20:29 +0000
Subject: Re: [PATCH v4 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <145a745d-6035-d082-c088-432c7a918fcd@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148363729327.11570.6244765717789390817.stgit@hbathini.in.ibm.com>
 <148363740554.11570.4870634597647436827.stgit@hbathini.in.ibm.com>
 <87tw8umged.fsf@concordia.ellerman.id.au>
In-Reply-To: <87tw8umged.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dyoung@redhat.com, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com



On Friday 20 January 2017 11:17 AM, Michael Ellerman wrote:
> Hari Bathini <hbathini@linux.vnet.ibm.com> writes:
>
>> Get rid of multiple definitions of append_elf_note() & final_note()
>> functions. Reuse these functions compiled under CONFIG_CRASH_CORE
>> Also, define Elf_Word and use it instead of generic u32 or the more
>> specific Elf64_Word.
>>
>> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
>> ---
>>
>> Changes from v3:
>> * Dropped hard-coded values and used DIV_ROUND_UP().
>>
>> Changes from v2:
>> * Added a definition for Elf_Word.
>> * Used IA64 version of append_elf_note() and final_note() functions.
>>
>>
>>   arch/ia64/kernel/crash.c   |   22 ----------------------
>>   include/linux/crash_core.h |    4 ++++
>>   include/linux/elf.h        |    2 ++
>>   kernel/crash_core.c        |   34 ++++++++++++++--------------------
>>   kernel/kexec_core.c        |   28 ----------------------------
>>   5 files changed, 20 insertions(+), 70 deletions(-)
> Do the powerpc patches later in the series actually depend on this one?
> Or is this just an unrelated cleanup?
>
> As it is I can't merge the series until we at least get an ack on this
> from the ia64 folks.
>
> If you can just split this out as a separate patch that would make it a
> lot easier to get the rest merged.
>

Hi Michael,

append_elf_note() & final_note() functions were defined statically at 
three different places,
arch/powerpc/kernel/fadump.c being one of them. With my changes, I would 
need to add
a fourth static definition if I ignore this cleanup. So, I preferred to 
clean this up...

Let me ping IA64 folks one last time. Will do a respin without the 
cleanup if I don't get
any response from them by end of this week..

Thanks
Hari

