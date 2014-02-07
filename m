From: Sander Eikelenboom <linux@eikelenboom.it>
Date: Fri, 07 Feb 2014 11:03:57 +0000
Subject: Re: [PATCH v2] Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the primary prevents
Message-Id: <652007466.20140207120357@eikelenboom.it>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140130000831.GJ16825@google.com> <1391160503-11122-1-git-send-email-linux@eikelenboom.it> <20140203145205.GB2992@phenom.dumpdata.com>
In-Reply-To: <20140203145205.GB2992@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Dave Airlie <airlied@redhat.com>, Eiichiro Oiwa <eiichiro.oiwa.nm@hitachi.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>, "linux-pci @ vger . kernel . org" <linux-pci@vger.kernel.org>, linux-ia64@vger.kernel.org

Hi All,

Still trying to collect tested and acked-by's ..

Dave,
          In commit 6cf20beec4b91c240cf759b4db72669e251f1fc4 you changed pci_fixup_video saying:
          "This fixes the switcheroo on my T410s."
          Do you still have the machine and could you verify if it still works with this patch applied ?

Eiichiro,
          Most of last major overhaul of pci_fixup_video was in commit 6b5c76b8e2ff204fa8d7201acce461188873bf2b saying:
          "PCI: fix pci_fixup_video as it blows up on sparc64"
          Is it possible for you to verify you can still boot on sparc64 with this patch applied ?

Tony,
          Since ia64's pci_fixup_video is also changed to be inline with x86, could you verify it still compiles and boots for you ?


Konrad,
          Thanks for reviewing and testing !

--
Sander




Monday, February 3, 2014, 3:52:05 PM, you wrote:

> On Fri, Jan 31, 2014 at 10:28:22AM +0100, Sander Eikelenboom wrote:
>> Hi Bjorn / Tony,
>> 
>> I fixed up ia64 as well and brought it inline again with the x86 code,
>> but i don't have a ia64 machine, so that part is untested.
>> Perhaps Tony is able to review/test it ?
>> 
>> Sander
>> 
>> 
>> 
>> Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the primary
>> prevents it from reading it's own rom. It will get the content of the shadowrom
>> at C000 instead, which is of the primary VGA card and the driver of the
>> secondary card will bail out.
>> 
>> Fix this by checking if the arch code or vga-arbitration has already
>> determined the vga_default_device, if so only apply the fix to this
>> primary video device and let the comment reflect this.
>> 
>> v2:
>>     - Fix pci_fixup_video both in x86 and ia64
>> 
>> 
>> Sander Eikelenboom (1):
>>   Setting the IORESOURCE_ROM_SHADOW flag on a VGA card other than the
>>     primary     prevents it from reading it's own rom. It will get the
>>     content of the shadowrom     at C000 instead, which is of the
>>     primary VGA card and the driver of the     secondary card will bail
>>     out.

> Your editor mutilated your subject line. It ought to have been just
> one line.

> Anyhow, you can also add 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com'
> on the patch for the x86 part.

> The ia64 "looks" OK to me, but my ia64 box won't boot v3.11 or later
> so I can't give it a 'Tested-by' yet.

>> 
>>  arch/ia64/pci/fixup.c |   24 +++++++++++++-----------
>>  arch/x86/pci/fixup.c  |   18 ++++++++++--------
>>  2 files changed, 23 insertions(+), 19 deletions(-)
>> 
>> -- 
>> 1.7.10.4
>> 


