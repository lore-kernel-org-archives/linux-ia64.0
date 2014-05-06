From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 06 May 2014 19:24:38 +0000
Subject: Re: [PATCH] ACPI / PCI: Stub out pci_acpi_crs_quirks() and make it x86 specific
Message-Id: <CAErSpo5q1dH1OURw23Qp313sDWPn61dzY5qfkpHB5JJvEQtrpg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399346670-6525-1-git-send-email-hanjun.guo@linaro.org> <1758433.vFPxG3NoOj@vostro.rjw.lan>
In-Reply-To: <1758433.vFPxG3NoOj@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Hanjun Guo <hanjun.guo@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Lv Zheng <lv.zheng@intel.com>, Tony Luck <tony.luck@intel.com>, Yijing Wang <wangyijing@huawei.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, linaro-acpi@lists.linaro.org

On Tue, May 6, 2014 at 5:28 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Tuesday, May 06, 2014 11:24:30 AM Hanjun Guo wrote:
>> For pci_acpi_crs_quirks(), ia64 already doesn't use it, and we can
>> not foresee it should be used in ARM64, so stub out pci_acpi_crs_quirks()
>> to avoid introducing platform specific dummy stub function.
>>
>> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
>
> Bjorn, what do you think?

Looks OK to me.  If you want to avoid the ifdef, we could put an empty
weak version in pci_root.c.  Either way,

Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>

>> ---
>>  arch/ia64/include/asm/acpi.h |    1 -
>>  include/acpi/acpi_drivers.h  |    5 +++++
>>  2 files changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
>> index d651102..97cb160 100644
>> --- a/arch/ia64/include/asm/acpi.h
>> +++ b/arch/ia64/include/asm/acpi.h
>> @@ -92,7 +92,6 @@ ia64_acpi_release_global_lock (unsigned int *lock)
>>  #endif
>>  #define acpi_processor_cstate_check(x) (x) /* no idle limits on IA64 :) */
>>  static inline void disable_acpi(void) { }
>> -static inline void pci_acpi_crs_quirks(void) { }
>>
>>  #ifdef CONFIG_IA64_GENERIC
>>  const char *acpi_get_sysname (void);
>> diff --git a/include/acpi/acpi_drivers.h b/include/acpi/acpi_drivers.h
>> index d504613..ea6428b 100644
>> --- a/include/acpi/acpi_drivers.h
>> +++ b/include/acpi/acpi_drivers.h
>> @@ -96,7 +96,12 @@ struct pci_dev *acpi_get_pci_dev(acpi_handle);
>>  /* Arch-defined function to add a bus to the system */
>>
>>  struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root);
>> +
>> +#ifdef CONFIG_X86
>>  void pci_acpi_crs_quirks(void);
>> +#else
>> +static inline void pci_acpi_crs_quirks(void) { }
>> +#endif
>>
>>  /* --------------------------------------------------------------------------
>>                                      Processor
>>
>
> --
> I speak only for myself.
> Rafael J. Wysocki, Intel Open Source Technology Center.
