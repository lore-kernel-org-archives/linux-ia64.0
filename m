From: Zwane Mwaikambo <zwane@linuxpower.ca>
Date: Thu, 30 Sep 2004 13:03:56 +0000
Subject: Re: [ACPI] [PATCH] Updated patches for PCI IRQ resource deallocation
Message-Id: <Pine.LNX.4.61.0409301601240.3069@musoma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.53.0409251356110.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251401560.2914@musoma.fsmlabs.com>
 <Pine.LNX.4.53.0409251416570.2908@musoma.fsmlabs.com> <4157A9D7.4090605@jp.fujitsu.com>
 <Pine.LNX.4.61.0409281702580.3052@musoma.fsmlabs.com> <415A28B9.6080504@jp.fujitsu.com>
 <Pine.LNX.4.61.0409291809270.3056@musoma.fsmlabs.com> <415B8A16.9070101@jp.fujitsu.com>
In-Reply-To: <415B8A16.9070101@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, long <tlnguyen@snoqualmie.dp.intel.com>, Andrew Morton <akpm@osdl.org>, Greg Kroah-Hartmann <greg@kroah.com>, Len Brown <len.brown@intel.com>, tony.luck@intel.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

On Thu, 30 Sep 2004, Kenji Kaneshige wrote:

> Zwane Mwaikambo wrote:
> > 
> > Ok i think i may have not conveyed my meaning properly, my mistake. What i
> > think would be better is if the architectures which have no-op
> > acpi_unregister_gsi to declare them as static inline in header files. For
> > architectures (such as ia64) which have a functional acpi_unregister_gsi, we
> > can declare them in a .c file with the proper exports etc.
> > 
> 
> Now I (maybe) properly understand what you mean :-). But I still have one
> concern about your idea.
> 
> For architectures which have a functional acpi_unregister_gsi, we need to
> declare "extern void acpi_unregister_gsi(int gsi);" in include/linux/acpi.h
> that is common to all architectures. I think include/linux/acpi.h is the
> best place to declare it because acpi_register_gsi(), opposite portion of
> acpi_unregister_gsi(), is declared in it. On the other hand, for archtectures
> that have no-op acpi_unregister_gsi(), acpi_unregister_gsi() is defined as
> static inline function in arch specific header files. This looks not natural
> to me.

Can't you declare "extern void acpi_unregister_gsi(int gsi)" in 
include/asm/acpi.h? That way it stays arch specific and you don't have the 
conflicting declarations. You can also move acpi_unregister_gsi into arch 
specific headers too.

Thanks,
	Zwane
