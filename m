From: Fabien Lebaillif - Delamare <fabien@quadrics.com>
Date: Tue, 29 Oct 2002 10:57:51 +0000
Subject: [Linux-ia64] EFI Boot Manager vs. elilo textmenu chooser
Message-Id: <marc-linux-ia64-105590709805282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What is the main advantage/difference of using 

efibootmgr -c -L "My Wannabe Kernel" -d /dev/sda -l
"\\efi\\WhatEverDir\\elilo3.3a.efi" MyKernelVersion
with an entry into elilo.conf for "MyKernelVersion" and chooser set to
simple.

which create an entry into EFI Boot mgr menu, so when you press enter in
the menu you just boot to your kernel.

over

elilo with chooser=textmenu as in the examples provided with elilo3.3a
sources ? 

Result you end up with 2 menus; you can choose your kernel from the EFI
menu and then choose another one from the elilo menu.

What is the usage (standard)? 

- only one entry in EFI ( for all kernels) to elilo and then elilo doing
the menu thing
 
- as many entries in EFI boot mgr as kernel installed on the system
linked to elilo just to load them?

- or no EFI boot mgr entries at all and just a startup.nsh script which
just call elilo and then elilo doing the menu thing ?

- or what ever combination of all the different possiblity ?

Two menu isnt't a bit redoundant ?

thx
-- 
	-fabien-


