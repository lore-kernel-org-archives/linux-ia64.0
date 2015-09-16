From: Al Stone <al.stone@linaro.org>
Date: Wed, 16 Sep 2015 16:24:33 +0000
Subject: Re: [PATCH v3 0/5] ACPI: Provide better MADT subtable sanity checks
Message-Id: <55F997C1.20606@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
 <55F889E8.3070706@redhat.com> <1880799.vMhNVMG5Vc@vostro.rjw.lan>
In-Reply-To: <1880799.vMhNVMG5Vc@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Al Stone <ahs3@redhat.com>
Cc: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, "lenb@kernel.org" <lenb@kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, Pavel Machek <pavel@ucw.cz>, "tglx@linutronix.de" <tglx@linutronix.de>, mingo@redhat.com, "H. Peter Anvin" <hpa@linux.intel.com>

On 09/15/2015 08:44 PM, Rafael J. Wysocki wrote:
> On Tuesday, September 15, 2015 03:13:12 PM Al Stone wrote:
>> On 09/09/2015 03:09 PM, Al Stone wrote:
>>> Currently, the BAD_MADT_ENTRY macro is used to do a very simple sanity
>>> check on the various subtables that are defined for the MADT.  The check
>>> compares the size of the subtable data structure as defined by ACPICA to
>>> the length entry in the subtable.  If they are not the same, the assumption
>>> is that the subtable is incorrect.
>>>
>>> Over time, the ACPI spec has allowed for MADT subtables where this can
>>> never be true (the local SAPIC subtable, for example).  Or, more recently,
>>> the spec has accumulated some minor flaws where there are three possible 
>>> sizes for a subtable, all of which are valid, but only for specific versions
>>> of the spec (the GICC subtable).  In both cases, BAD_MADT_ENTRY reports these
>>> subtables as bad when they are not.  In order to retain some sanity check
>>> on the MADT subtables, we now have to special case these subtables.  Of
>>> necessity, these special cases have ended up in arch-dependent code (arm64)
>>> or an arch has simply decided to forgo the check (ia64).
>>>
>>> This patch set replaces the BAD_MADT_ENTRY macro with a function called
>>> bad_madt_entry().  This function uses a data set of details about the
>>> subtables to provide more sanity checking than before:
>>>
>>> 	-- is the subtable legal for the version given in the FADT?
>>>
>>> 	-- is the subtable legal for the revision of the MADT in use?
>>>
>>> 	-- is the subtable of the proper length (including checking
>>> 	   on the one variable length subtable that is currently ignored),
>>> 	   given the FADT version and the MADT revision?
>>>
>>> Further, this patch set adds in the call to bad_madt_entry() from the 
>>> acpi_table_parse_madt() function, allowing it to be used consistently
>>> by all architectures, for all subtables, and removing the need for each
>>> of the subtable traversal callback functions to use BAD_MADT_ENTRY.
>>>
>>> In theory, as the ACPI specification changes, we would only have to add
>>> additional information to the data set describing the MADT subtables in
>>> order to continue providing sanity checks, even when new subtables are
>>> added.
>>>
>>> These patches have been tested on an APM Mustang (arm64) and are known to
>>> work there.  They have also been cross-compiled for x86 and ia64 with no
>>> known failures.
>>>
>>> Changes for v3:
>>>    -- Reviewed-and-tested-by from Sudeep Holla for arm64 parts
>>>    -- Clearer language in error messages (Graeme Gregory, Timur Tabi)
>>>    -- Double checked that inserting call to bad_madt_entry() into the
>>>       function acpi_parse_entries() does not impact current behavior
>>>       (Sudeep Holla)
>>>    
>>> Changes for v2:
>>>    -- Acked-by on 2/5 from Marc Zyngier and Catalin Marinas for ARM
>>>    -- Correct faulty end of loop test found by Timur Tabi
>>>
>>>
>>> Al Stone (5):
>>>   ACPI: add in a bad_madt_entry() function to eventually replace the
>>>     macro
>>>   ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
>>>   ACPI / IA64: remove usage of BAD_MADT_ENTRY
>>>   ACPI / X86: remove usage of BAD_MADT_ENTRY
>>>   ACPI: remove definition of BAD_MADT_ENTRY macro
>>>
>>>  arch/arm64/include/asm/acpi.h |   8 --
>>>  arch/arm64/kernel/smp.c       |   2 -
>>>  arch/ia64/kernel/acpi.c       |  20 ----
>>>  arch/x86/kernel/acpi/boot.c   |  27 -----
>>>  drivers/acpi/tables.c         | 245 +++++++++++++++++++++++++++++++++++++++++-
>>>  drivers/irqchip/irq-gic.c     |   6 --
>>>  include/linux/acpi.h          |   4 -
>>>  7 files changed, 244 insertions(+), 68 deletions(-)
>>>
>>
>> Ping?  Any additional comments on this version?  I have only received
>> feedback from arm64 reviewers so far, over three revisions, even though
>> everyone that needs to be (ACPI, ia64, x86) has also been CCd.
>>
>> Anyone else before I fix a couple of things for v4 that the arm64 folks
>> found?  ACKs?  NAKs?  Please don't bother me, I'm in the merge window :)?
> 
> The merge window is actually over, so why would you expect anything like that?

I know.  Merely a feeble attempt at humor....

> I'm going to apply this series if people have no problems with it.  I do think
> it is slightly overkill, but then as long as it works ...
> 
> Thanks,
> Rafael
> 

Thanks, Rafael.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Linaro Enterprise Group
al.stone@linaro.org
-----------------------------------
