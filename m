From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Mon, 14 Nov 2016 10:29:14 +0000
Subject: Re: [PATCH 1/3] crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
Message-Id: <bb361dbd-e5ad-fae3-39db-e0a39b6b0fc5@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <147877899077.31483.3740501843050856595.stgit@hbathini.in.ibm.com>
 <147877904646.31483.2251653505359017982.stgit@hbathini.in.ibm.com>
 <20161114053627.GC19995@x1>
In-Reply-To: <20161114053627.GC19995@x1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoquan He <bhe@redhat.com>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dyoung@redhat.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com



On Monday 14 November 2016 11:06 AM, Baoquan He wrote:
> On 11/10/16 at 05:27pm, Hari Bathini wrote:
>> Traditionally, kdump is used to save vmcore in case of a crash. Some
>> architectures like powerpc can save vmcore using architecture specific
>> support instead of kexec/kdump mechanism. Such architecture specific
>> support also needs to reserve memory, to be used by dump capture kernel.
>> crashkernel parameter can be a reused, for memory reservation, by such
>> architecture specific infrastructure.
>>
>> But currently, code related to vmcoreinfo and parsing of crashkernel
>> parameter is built under CONFIG_KEXEC_CORE. This patch introduces
>> CONFIG_CRASH_CORE and moves the above mentioned code under this config,
>> allowing code reuse without dependency on CONFIG_KEXEC. While here,
>> removing the multiple definitions of append_elf_note() and final_note()
>> for one defined under CONFIG_CONFIG_CORE. There is no functional change
>> with this patch.
> Can't think of a reason to object.
>
> Could it be that do the moving from kexec_core.c to crash_core.c only,
> then do the arch specific clean up in another patch?

Right. Will move arch specific code into a separate patch, on the
next version..

> Besides there's already a file crash_dump.h, can we reuse that?

Did think about it. But as it is meant for dump capture kernel
(CONFIG_CRASH_DUMP) and CONFIG_KEXEC_CORE being
independent, didn't pursue it..

Thanks
Hari

