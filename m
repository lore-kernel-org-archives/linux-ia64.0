From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 01 Oct 2004 07:49:27 +0000
Subject: Re: [ACPI] [PATCH] Updated patches for PCI IRQ resource deallocation
Message-Id: <415D0C07.2070806@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.53.0409251356110.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251401560.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251416570.2908@musoma.fsmlabs.com>
 <4157A9D7.4090605@jp.fujitsu.com>
 <Pine.LNX.4.61.0409281702580.3052@musoma.fsmlabs.com>
 <415A28B9.6080504@jp.fujitsu.com>
 <Pine.LNX.4.61.0409291809270.3056@musoma.fsmlabs.com>
 <415B8A16.9070101@jp.fujitsu.com>
 <Pine.LNX.4.61.0409301601240.3069@musoma.fsmlabs.com>
In-Reply-To: <Pine.LNX.4.61.0409301601240.3069@musoma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, long <tlnguyen@snoqualmie.dp.intel.com>, Andrew Morton <akpm@osdl.org>, Greg Kroah-Hartmann <greg@kroah.com>, Len Brown <len.brown@intel.com>, tony.luck@intel.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Zwane Mwaikambo wrote:

> 
> Can't you declare "extern void acpi_unregister_gsi(int gsi)" in 
> include/asm/acpi.h? That way it stays arch specific and you don't have the 
> conflicting declarations. You can also move acpi_unregister_gsi into arch 
> specific headers too.
> 

OK. I'll update my patch based on your feedback.

Thanks,
Kenji Kaneshige

