From: Sander Eikelenboom <linux@eikelenboom.it>
Date: Fri, 31 Jan 2014 09:28:22 +0000
Subject: [PATCH v2] Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the primary prevents it f
Message-Id: <1391160503-11122-1-git-send-email-linux@eikelenboom.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140130000831.GJ16825@google.com>
In-Reply-To: <20140130000831.GJ16825@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Tony Luck <tony.luck@intel.com>, Dave Airlie <airlied@redhat.com>, Eiichiro Oiwa <eiichiro.oiwa.nm@hitachi.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Sander Eikelenboom <linux@eikelenboom.it>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>, "linux-pci @ vger . kernel . org" <linux-pci@vger.kernel.org>, linux-ia64@vger.kernel.org

Hi Bjorn / Tony,

I fixed up ia64 as well and brought it inline again with the x86 code,
but i don't have a ia64 machine, so that part is untested.
Perhaps Tony is able to review/test it ?

Sander



Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the primary
prevents it from reading it's own rom. It will get the content of the shadowrom
at C000 instead, which is of the primary VGA card and the driver of the
secondary card will bail out.

Fix this by checking if the arch code or vga-arbitration has already
determined the vga_default_device, if so only apply the fix to this
primary video device and let the comment reflect this.

v2:
    - Fix pci_fixup_video both in x86 and ia64


Sander Eikelenboom (1):
  Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the
    primary     prevents it from reading it's own rom. It will get the
    content of the shadowrom     at C000 instead, which is of the
    primary VGA card and the driver of the     secondary card will bail
    out.

 arch/ia64/pci/fixup.c |   24 +++++++++++++-----------
 arch/x86/pci/fixup.c  |   18 ++++++++++--------
 2 files changed, 23 insertions(+), 19 deletions(-)

-- 
1.7.10.4

