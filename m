From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 28 Sep 2006 10:54:00 +0000
Subject: Re: [PATCH 2.6.18] PCI: Turn pci_fixup_video into generic for
Message-Id: <1159442302.11049.404.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <XNM1$9$0$4$$3$3$7$A$9002686U451b55cd@hitachi.com>
In-Reply-To: <XNM1$9$0$4$$3$3$7$A$9002686U451b55cd@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eiichiro.oiwa.nm@hitachi.com
Cc: akpm@osdl.org, tony.luck@intel.com, greg@kroah.com, Jesse Barnes <jesse.barnes@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Ar Iau, 2006-09-28 am 13:55 +0900, ysgrifennodd
eiichiro.oiwa.nm@hitachi.com:
> pci_fixup_video turns into generic code because there are many platforms need this fixup
> for embedded VGA as well as x86. The Video BIOS integrates into System BIOS on a machine
> has embedded VGA although embedded VGA generally don't have PCI ROM. As a result,
> embedded VGA need the way that the sysfs rom points to the Video BIOS of System
> RAM (0xC0000). PCI-to-PCI Bridge Architecture specification describes the condition whether
> or not PCI ROM forwards VGA compatible memory address. fixup_video suits this specification.
> Although the Video ROM generally implements in x86 code regardless of platform, some
> application such as X Window System can run this code by dosemu86. Therefore,
> pci_fixup_video should turn into generic code.
> 
> 
> Signed-off-by: Eiichiro Oiwa <eiichiro.oiwa.nm@hitachi.com>

Acked-by: Alan Cox <alan@redhat.com>

