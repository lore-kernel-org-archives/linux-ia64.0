From: "Eric Wang" <ericwang25@hotmail.com>
Date: Thu, 15 Jun 2000 09:40:50 +0000
Subject: Re: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

During the machine boot up period, the USB keyboard could not work, so you 
should connect both PS/2 and USB Mouse and Keyboard on the machine. After 
boot up, install TurboLinux build 5.5 (May 5?), it will install the USB 
keyboard driver. After the installation, start the Turbolinux OS, startx, 
you will see the USB keyboard is active. But the USB mouse could not work.

Eric




>From: Johannes Erdfelt <jerdfelt@valinux.com>
>To: Jonathan_Kwahk@Dell.com
>CC: linux-ia64@linuxia64.org
>Subject: Re: [Linux-ia64] USB Support
>Date: Tue, 13 Jun 2000 11:15:34 -0700
>
>On Tue, Jun 13, 2000, Jonathan_Kwahk@Dell.com <Jonathan_Kwahk@Dell.com> 
>wrote:
> > Is there any USB support in the installation yet? Or any at all?
>
>I haven't extensively tested this since all of the ia64 machines I have
>worked on have had PS/2 keyboards installed.
>
>There is 2 parts. The first is support in the BIOS and EFI. I have not
>tested this and I do not know if this works, but many ia32 machines do
>support this and I expect ia64 machines to as well.
>
>The second is the kernel. TurboLinux AFAICT compiles their kernels with
>USB support. It should support USB keyboards during install and after
>install. However, I have not tested this yet.
>
>I don't know if RedHat has compiled USB support into their kernel, but I
>suspect they do.
>
>JE
>
>
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org
>http://lists.linuxia64.org/lists/listinfo/linux-ia64

________________________________________________________________________
Get Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com



