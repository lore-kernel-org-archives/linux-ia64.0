From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 01 Nov 2002 17:48:51 +0000
Subject: Re: [Linux-ia64] EFI Boot Manager vs. elilo textmenu chooser
Message-Id: <marc-linux-ia64-105590709805325@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fabien,

On Tue, Oct 29, 2002 at 10:57:51AM +0000, Fabien Lebaillif - Delamare wrote:
> What is the main advantage/difference of using 
> 
> efibootmgr -c -L "My Wannabe Kernel" -d /dev/sda -l
> "\\efi\\WhatEverDir\\elilo3.3a.efi" MyKernelVersion
> with an entry into elilo.conf for "MyKernelVersion" and chooser set to
> simple.
> 
> which create an entry into EFI Boot mgr menu, so when you press enter in
> the menu you just boot to your kernel.
> 

That's the preferred way of doing things. It makes the process of selecting
which OS to boot identical. Remember that EFI is a Os neutral environment.
You can imagine a machine where Linux. Windows, and HPUX and installed and
you can choose to boot any one of them from the same menu.

> over
> 
> elilo with chooser=textmenu as in the examples provided with elilo3.3a
> sources ? 
> 
> Result you end up with 2 menus; you can choose your kernel from the EFI
> menu and then choose another one from the elilo menu.
> 
> 
This was added mostly to make the *installation* process (Debian) uniform
across platforms. 

> - only one entry in EFI ( for all kernels) to elilo and then elilo doing
> the menu thing
> 
As long as all options from the config file are available as command line
options, there is no real difference. You can imagine a scenario where the
Boot manager makes the OS selection and then a subsequent menu allows
you to optionally further refine your choice (UP vs. SMP, debug....). If
you don't like the cascading, then you can simply move everything into
the boot manager menu and get elilo to work quietly. Also note that the
textmenu chooser is not the only one, the simple chooser is very basic
and could almost be made transparent (no delay, no print).

> - as many entries in EFI boot mgr as kernel installed on the system
> linked to elilo just to load them?
> 

> - or no EFI boot mgr entries at all and just a startup.nsh script which
> just call elilo and then elilo doing the menu thing ?
> 
That's a no no. Startup.nsh is too risky. 

-- 
-Stephane

