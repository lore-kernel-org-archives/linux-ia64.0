From: Andreas Schwab <schwab@suse.de>
Date: Fri, 17 Oct 2003 12:17:09 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106639316505346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> On Fri, Oct 17, 2003 at 01:12:07PM +0200, Andreas Schwab wrote:
>> +EXPORT_SYMBOL(csum_partial);
>
> ok.
>
>> @@ -61,6 +62,8 @@
>>  #include <asm/pgtable.h>
>>  EXPORT_SYMBOL(vmalloc_end);
>>  EXPORT_SYMBOL(ia64_pfn_valid);
>> +EXPORT_SYMBOL(max_low_pfn);
>> +EXPORT_SYMBOL(vmem_map);
>
> what needs these?

Anything that uses virt_addr_valid (net/scpt).

>> +#include <linux/reboot.h>
>> +EXPORT_SYMBOL(machine_power_off);
>> +EXPORT_SYMBOL(machine_restart);
>
> dito.

drivers/char/watchdog/pcwd

>  If these are needed the export should probably go into
> architecture-independent code.

Those are architecture dependent functions, implemented under arch.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
