From: Matt_Domsch@Dell.com
Date: Wed, 16 May 2001 00:04:40 +0000
Subject: [Linux-ia64] Announcing efibootmgr-0.2.0
Message-Id: <marc-linux-ia64-105590693005585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Announcing efibootmgr-0.2.0, a Linux user-space application which interacts
with the EFI Boot Manager.  It may be downloaded from
http://domsch.com/linux/ia64/efibootmgr-0.2.0.tar.gz.

This requires the efivars module be loaded, and expects them 
to be at /proc/efi/vars/* which is consistent with the kernel 
2.4.4 IA-64 patch.  You must be root to run this (as /proc/efi/vars/* are
only read/write root).

This is a preliminary release, but seems to work for me.  I'd appreciate
people's feedback.  I suspect it's not quite ready for incorporation into
distributions.

By default, with -c, it creates a BootXXXX variable named "Linux", with an
EFI Device Path that includes HardDrive()/File(), but not the ACPI stuff.
This is per EFI spec, and works as long as disk unique signatures are truely
unique.
With -c -e 1, it creates an EDD 1.0 device path like Vendor()/HD()/File()
With -c -e 3, it creates an EDD 3.0 device path like
ACPI()/PCI()/SCSI()/HD()/File().

With no options, displays current Boot* variable information.  -v displays
the unparsed device path of each boot option.

 
usage: efibootmgr [options]
	   -a | --active          set bootnum active
	   -A | --inactive	  set bootnum inactive
         -b | --bootnum XXXX           use BootXXXX (hex)
         -B | --delete-bootnum XXXX    delete BootXXXX (hex)
         -c | --create            create new variable bootnum  and add to
bootorder
         -d | --disk disk       (defaults to /dev/sda)  containing loader
         -e | --edd [1|3|-1]       force EDD 1.0 or 3.0 creation variables
(or auto)
         -E | --device num      EDD 1.0 device number  (defaults to 0x80)
         -l | --loader name     (defaults to \elilo.efi)
         -L | --label label     Boot manager display label  (defaults to
"Linux")
         -n | --bootnext XXXX   set BootNext to XXXX (hex)
         -N | --delete-bootnext delete BootNext
         -o | --bootorder XXXX,YYYY,ZZZZ,...     explicitly set BootOrder
(hex)
         -O | --delete-bootorder delete BootOrder
         -p | --part part        (defaults to 1) containing loader
         -q | --quiet            be quiet
         -v | --verbose          print additional information
         -V | --version          return version and exit

 
 
 [root@localhost bootmgr]# ./elilo2bootmgr.bin -v
 BootNext: 0000
 BootOrder: 0000,0004
 Boot0000: Linux  Vendor(cf31fac5-c24e-11d2-85f3-00a0c93ec93b,80000000)
			HD(0,3f,32f8e,0x9674)File(\elilo.efi)
 Boot0004: Linux  ACPI(a0341d0,2)PCI(0,0)SCSI(0,0)
			HD(0,0,10bc000,0x9ec6)File(\elilo.efi)


Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



