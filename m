From: <eiichiro.oiwa.nm@hitachi.com>
Date: Thu, 28 Sep 2006 05:03:22 +0000
Subject: Re[2]: [PATCH 2.6.18] IA64: Add pci_fixup_video into IA64 kernel
Message-Id: <XNM1$9$0$4$$3$3$7$A$9002687U451b578f@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <XNM1$9$0$4$$3$3$7$A$9002684U451a5f21@hitachi.com> 
    <1159359135.11049.341.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jesse Barnes <jesse.barnes@intel.com>, akpm@osdl.org, tony.luck@intel.com, greg@kroah.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>Ar Mer, 2006-09-27 am 20:23 +0900, ysgrifennodd
>eiichiro.oiwa.nm@hitachi.com:
>> I moved pci_fixup_video to generic location (driver/pci/quirks.c).
>> I tested generic fixup_video on x86, x86_64 and IA64, and confirmed
>> we can read Video BIOS from the sysfs rom with embedded VGA.
>
>Lots of embedded systems don't have a PCI bios in the usual sense, and
>cannot run the x86 code in the ROM firmware either. That doesn't appear
>to be a big problem when setting PCI_ROM_SHADOW but those platforms may
>not all be able to access the shadow rom if one exists.
>
>Can you fix the comment in drivers/pci/rom.c to reflect the changes.
>
>Otherwise looks good.
>
>Alan
>

Thank you for some good advise.
I changed this subject to appropriate one:
[PATCH 2.6.18] PCI: Turn pci_fixup_video into generic for embedded VGA

Thanks,
Eiichiro
