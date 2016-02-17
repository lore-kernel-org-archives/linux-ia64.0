From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 17 Feb 2016 16:10:11 +0000
Subject: Re: [PATCH v3 5/5] ACPI / processor_idle: Add support for Low Power Idle(LPI) states
Message-Id: <56C49B63.9050102@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <1449065446-26115-6-git-send-email-sudeep.holla@arm.com>
 <8070621.77MVWuTaHa@vostro.rjw.lan>
In-Reply-To: <8070621.77MVWuTaHa@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>



On 16/02/16 20:46, Rafael J. Wysocki wrote:
> On Wednesday, December 02, 2015 02:10:46 PM Sudeep Holla wrote:
>> ACPI 6.0 introduced an optional object _LPI that provides an alternate
>> method to describe Low Power Idle states. It defines the local power
>> states for each node in a hierarchical processor topology. The OSPM can
>> use _LPI object to select a local power state for each level of processor
>> hierarchy in the system. They used to produce a composite power state
>> request that is presented to the platform by the OSPM.
>>
>> Since multiple processors affect the idle state for any non-leaf hierarchy
>> node, coordination of idle state requests between the processors is
>> required. ACPI supports two different coordination schemes: Platform
>> coordinated and  OS initiated.
>>
>> This patch adds initial support for Platform coordination scheme of LPI.
>>
>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
>
> My first point here would be the same as for [4/5]: please don't introduce
> new Kconfig options if you don't have to (and you clearly don't have to in this
> case, because it all can be made work without new Kconfig options).
>

Right, this was kind of defensive approach initially so as to not break
anything on x86, rather add anything new to x86 code path. I have
removed it now.

>> ---
>>   drivers/acpi/Kconfig            |   3 +
>>   drivers/acpi/bus.c              |   8 +-
>>   drivers/acpi/processor_driver.c |   2 +-
>>   drivers/acpi/processor_idle.c   | 440 +++++++++++++++++++++++++++++++++++-----
>>   include/acpi/processor.h        |  30 ++-
>>   include/linux/acpi.h            |   4 +
>>   6 files changed, 435 insertions(+), 52 deletions(-)
>>
>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>> index 12873f0b8141..89a2d9b81feb 100644
>> --- a/drivers/acpi/Kconfig
>> +++ b/drivers/acpi/Kconfig
>> @@ -51,6 +51,9 @@ config ARCH_MIGHT_HAVE_ACPI_PDC
>>   config ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
>>   	bool
>>
>> +config ARCH_SUPPORTS_ACPI_PROCESSOR_LPI
>
> Not needed.
>

Done

>> +	bool
>> +
>>   config ACPI_GENERIC_GSI
>>   	bool
>>
>> diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
>> index a212cefae524..2e9e2e3fde6a 100644
>> --- a/drivers/acpi/bus.c
>> +++ b/drivers/acpi/bus.c
>> @@ -301,6 +301,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct acpi_osc_context *context)
>>   EXPORT_SYMBOL(acpi_run_osc);
>>
>>   bool osc_sb_apei_support_acked;
>> +bool osc_pc_lpi_support_acked;
>
> Maybe call it osc_pc_lpi_support_confirmed.  And add a comment describing what
> "PC LPI" means (a pointer to the relevant spec section might be useful too).
>

Agreed and done

[...]

>> @@ -943,24 +906,407 @@ static inline void acpi_processor_cstate_first_run_checks(void)
>>
>>   static inline int disabled_by_idle_boot_param(void) { return 0; }
>>   static inline void acpi_processor_cstate_first_run_checks(void) { }
>> -static int acpi_processor_get_power_info(struct acpi_processor *pr)
>> +static int acpi_processor_get_cstate_info(struct acpi_processor *pr)
>>   {
>>   	return -ENODEV;
>>   }
>> -
>
> Unrelated whitespace change.
>

Removed

[...]

>> +
>> +	/* There must be at least 4 elements = 3 elements + 1 package */
>> +	if (!lpi || lpi->type != ACPI_TYPE_PACKAGE || lpi->package.count < 4) {
>> +		pr_info("not enough elements in _LPI\n");
>
> pr_debug()?  Plus maybe point to the LPI object in question in that message?
>
>> +		ret = -EFAULT;
>
> -ENXIO?  -EFAULT has a specific meaning which doesn't apply here.
>

Both done

>> +
>> +		/* TODO this long list is looking insane now
>> +		 * need a cleaner and saner way to read the elements
>> +		 */
>
> Well, I'm not sure about the above comment.  The code is what it is, anyone
> can draw their own conclusions. :-)
>

Well that's stray leftover comment. When I started adding LPI changes, I
initially thought they may be better way to do that, but I have now
realized it's only way :). I will remove it


> I would consider storing the whole buffer instead of trying to decode it
> upfront, though.  You need to flatten it etc going forward, so maybe
> decode it at that time?
>

OK, I will look at this now.

> Also I'm not sure about silent discarding things that look defective.  I would
> at least add a debug message to wherever this is done and maybe we can try
> to fix up or fall back to some sane defaults at least in some cases?
>

Agreed.



[...]

>> +	info = kcalloc(max_leaf_depth + 1, sizeof(*info), GFP_KERNEL);
>> +	if (!info)
>> +		return -ENOMEM;
>> +
>> +	phandle = pr->handle;
>
> phandle is easily confised with DT phandles.  I'd avoind using that for an ACPI
> object handle variable name.
>

I changed it to pr_ahandle now(i.e processor acpi handle)


> Well, what if it turns out that LPI is missing?  Shouldn't we fall back to using
> _CST then?
>
> Of course, the problem here is that the presence of LPI has to be checked for
> all CPUs in the system before deciding to fall back (in which case all of them
> should be using _CST if present).
>

I agree, do we do similar check for _CST too ?


>> +	dev->cpu = pr->id;
>> +	if (pr->flags.has_lpi)
>> +		return acpi_processor_ffh_lpi_probe(pr->id);
>> +	else
>> +		return acpi_processor_setup_cpuidle_cx(pr, dev);
>
> Fallback here too maybe?
>

Fixed

>> +}
>> +
>> +static int acpi_processor_get_power_info(struct acpi_processor *pr)
>> +{
>> +	int ret = 0;
>> +
>> +	ret = acpi_processor_get_cstate_info(pr);
>> +	if (ret)
>> +		ret = acpi_processor_get_lpi_info(pr);
>
> Shouldn't that be done in the reverse order?
>

Yes, again kind of defensive approach I took to avoid any change, but
will change it.

>> diff --git a/include/acpi/processor.h b/include/acpi/processor.h
>> index 50f2423d31fa..f3006831d427 100644
>> --- a/include/acpi/processor.h
>> +++ b/include/acpi/processor.h
>> @@ -39,6 +39,7 @@
>>   #define ACPI_CSTATE_SYSTEMIO	0
>>   #define ACPI_CSTATE_FFH		1
>>   #define ACPI_CSTATE_HALT	2
>> +#define ACPI_CSTATE_INTEGER	3
>
> What does this mean?
>

Ah bad naming, I introduced this to communicate to flattening algo that
it's a simple number that needs to used as is. Based on you comment
above, saving buffer and decoding later might remove the need of it.

-- 
Regards,
Sudeep
