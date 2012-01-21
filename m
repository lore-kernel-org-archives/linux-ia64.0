From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sat, 21 Jan 2012 20:38:27 +0000
Subject: Re: [PATCH 2/3] ACPI, APEI: Add RAM mapping support to ACPI
Message-Id: <CAErSpo5jofU94+8p3h8_TZ2bCiSWGZKL57sZ311R9kC_HhqC7g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120121021318.14723.45698.stgit@amt.stowe> <20120121021330.14723.72537.stgit@amt.stowe>
 <CAErSpo5KDxkcMn3OrvujeSHhzF7PjG0hsYqMXe1HmpPJaLHvDg@mail.gmail.com>
In-Reply-To: <CAErSpo5KDxkcMn3OrvujeSHhzF7PjG0hsYqMXe1HmpPJaLHvDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Myron Stowe <myron.stowe@redhat.com>
Cc: lenb@kernel.org, linux-acpi@vger.kernel.org, rjw@sisk.pl, ying.huang@intel.com, trenn@suse.de, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

+cc Tony, linux-ia64

On Sat, Jan 21, 2012 at 8:04 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> On Fri, Jan 20, 2012 at 7:13 PM, Myron Stowe <myron.stowe@redhat.com> wro=
te:
>> From: Myron Stowe <mstowe@redhat.com>
>>
>> This patch adds support for RAM to ACPI's mapping capabilities in order
>> to support APEI error injection (EINJ) actions.
>>
>> This patch re-factors similar functionality introduced in commit
>> 76da3fb3575, bringing it into osl.c in preparation for removing
>> ./drivers/acpi/atomicio.[ch].
>>
>> Signed-off-by: Myron Stowe <myron.stowe@redhat.com>
>> ---
>>
>> =A0drivers/acpi/osl.c | =A0 36 ++++++++++++++++++++++++++++++++++--
>> =A01 files changed, 34 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
>> index f363a55..8ee64ea 100644
>> --- a/drivers/acpi/osl.c
>> +++ b/drivers/acpi/osl.c
>> @@ -31,6 +31,7 @@
>> =A0#include <linux/kernel.h>
>> =A0#include <linux/slab.h>
>> =A0#include <linux/mm.h>
>> +#include <linux/highmem.h>
>> =A0#include <linux/pci.h>
>> =A0#include <linux/interrupt.h>
>> =A0#include <linux/kmod.h>
>> @@ -321,6 +322,37 @@ acpi_map_lookup_virt(void __iomem *virt, acpi_size =
size)
>> =A0 =A0 =A0 =A0return NULL;
>> =A0}
>>
>> +#ifndef CONFIG_IA64
>> +#define should_use_kmap(pfn) =A0 page_is_ram(pfn)
>> +#else
>> +/* ioremap will take care of cache attributes */
>> +#define should_use_kmap(pfn) =A0 0
>> +#endif
>> +
>> +static void __iomem *acpi_map(acpi_physical_address pg_off, unsigned lo=
ng pg_sz)
>> +{
>> + =A0 =A0 =A0 unsigned long pfn;
>> +
>> + =A0 =A0 =A0 pfn =3D pg_off >> PAGE_SHIFT;
>> + =A0 =A0 =A0 if (should_use_kmap(pfn)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pg_sz > PAGE_SIZE)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (void __iomem __force *)kmap(pfn_to=
_page(pfn));
>> + =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return acpi_os_ioremap(pg_off, pg_sz);
>
> This implies that ioremap() works differently on ia64 than on x86.
> Apparently one can ioremap() RAM on x86, but not on ia64. =A0Why is this
> different? =A0Shouldn't we instead fix ioremap() on ia64 so it works the
> same as on x86?
>
> I looked at the ia64 ioremap(), and I can't see the reason it fails
> for RAM. =A0Huang, do you remember the details from 76da3fb3575?
>
>> +}
>> +
>> +static void acpi_unmap(acpi_physical_address pg_off, void __iomem *vadd=
r)
>> +{
>> + =A0 =A0 =A0 unsigned long pfn;
>> +
>> + =A0 =A0 =A0 pfn =3D pg_off >> PAGE_SHIFT;
>> + =A0 =A0 =A0 if (page_is_ram(pfn))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kunmap(pfn_to_page(pfn));
>> + =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(vaddr);
>
> I hope we can resolve the ioremap() question so we don't need this
> patch at all. =A0But if we do need this, I don't like the asymmetry here
> -- on x86 RAM, I think we use ioremap() and kunmap(), which seems
> wrong. =A0We should be able to use ioremap() and iounmap().
>
>> +}
>> +
>> =A0void __iomem *__init_refok
>> =A0acpi_os_map_memory(acpi_physical_address phys, acpi_size size)
>> =A0{
>> @@ -353,7 +385,7 @@ acpi_os_map_memory(acpi_physical_address phys, acpi_=
size size)
>>
>> =A0 =A0 =A0 =A0pg_off =3D round_down(phys, PAGE_SIZE);
>> =A0 =A0 =A0 =A0pg_sz =3D round_up(phys + size, PAGE_SIZE) - pg_off;
>> - =A0 =A0 =A0 virt =3D acpi_os_ioremap(pg_off, pg_sz);
>> + =A0 =A0 =A0 virt =3D acpi_map(pg_off, pg_sz);
>> =A0 =A0 =A0 =A0if (!virt) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&acpi_ioremap_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(map);
>> @@ -384,7 +416,7 @@ static void acpi_os_map_cleanup(struct acpi_ioremap =
*map)
>> =A0{
>> =A0 =A0 =A0 =A0if (!map->refcount) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0synchronize_rcu();
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(map->virt);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 acpi_unmap(map->phys, map->virt);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(map);
>> =A0 =A0 =A0 =A0}
>> =A0}
>>
