From: Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>
Date: Sat, 05 Jun 2004 01:09:36 +0000
Subject: Re: EFI-support for SMBIOS driver
Message-Id: <200406050309.36397.bzolnier@elka.pw.edu.pl>
List-Id: <linux-ia64.vger.kernel.org>
References: <16577.6469.833064.763671@napali.hpl.hp.com>
In-Reply-To: <16577.6469.833064.763671@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, David Mosberger <davidm@napali.hpl.hp.com>, Michael_E_Brown@dell.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


It seems SMBIOS driver is gone.

http://linus.bkbits.net:8080/linux-2.5/cset@40b6702axansvQIxOVjTSIp7_DVoHA

On Saturday 05 of June 2004 02:52, David Mosberger wrote:
> Michael,
>
> The patch below adds EFI support to the SMBIOS driver.  Since EFI
> already knows the address of the SMBIOS, this avoids having to scan
> for the table.  It also enables use of the driver on ia64 machines.
> The patch also adds code to handle the case where the SMBIOS table
> resides in memory, which is the case at least for HP's zx1-based ia64
> machines.  If CONFIG_EFI is off, the resulting code should be
> unchanged (except for replacing a readb() loop into a
> memcpy_fromio()).
>
> One observation: I believe find_table_max_address() is missing some
> readb() calls (it's dereferencing ioremap'pped addresses directly).  I
> didn't try to fix that since I wasn't sure why it wasn't done in the
> first place.
>
> Do you have a test-program that's using /sys/firmware/smbios?
>
> If the patch looks OK, please apply.
>
> Thanks,
>
> 	--david

