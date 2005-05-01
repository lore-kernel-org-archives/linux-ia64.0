From: Pavel Machek <pavel@ucw.cz>
Date: Sun, 01 May 2005 19:57:56 +0000
Subject: Re: [patch] properly stop devices before poweroff
Message-Id: <20050501195756.GD1909@elf.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421111346.GA21421@elf.ucw.cz> <20050429061825.36f98cc0.akpm@osdl.org> <42752954.5050600@jp.fujitsu.com>
In-Reply-To: <42752954.5050600@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi!

> >>Without this patch, Linux provokes emergency disk shutdowns and
> >>similar nastiness. It was in SuSE kernels for some time, IIRC.
> >>
> >
> >
> >With this patch when running `halt -p' my ia64 Tiger (using
> >tiger_defconfig) gets a stream of badnesses in iosapic_unregister_intr()
> >and then hangs up.
> >
> >Unfortunately it all seems to happen after the serial port has been
> >disabled because nothing comes out.  I set the console to a squitty font
> >and took a piccy.  See
> >http://www.zip.com.au/~akpm/linux/patches/stuff/dsc02505.jpg
> >
> >I guess it's an ia64 problem.  I'll leave the patch in -mm for now.
> >
> 
> I guess the stream of badness was occured as follows:
> 
>    pcibios_disable_device() for ia64 assumes that pci_enable_device()
>    and pci_disable_device() are balanced. But with 'properly stop
>    devices before power off' patch, pci_disable_device() becomes to be
>    called twice for e1000 device at halt time, through reboot_notifier_list
>    callback and through device_suspend(). As a result, 
>    iosapic_unregister_intr()
>    was called for already unregistered gsi and then stream of badness
>    was displayed.
> 
> I think the following patch will remove this stream of badness. I'm
> sorry but I have not checked if the stream of badness is actually
> removed because I'm on vacation and I can't look at my display
> (I'm working via remote console). Could you try this patch?
> 
> By the way, I don't think this stream of badness is related to hang up,
> because the problem (hang up) was reproduced even on my test kernel that
> doesn't call pcibios_disable_device().

Looks good to me. Plus I guess we should remove reboot notifier from
e1000... It should be obsoleted by driver model.
								Pavel

-- 
Boycott Kodak -- for their patent abuse against Java.
