From: Matt_Domsch@Dell.com
Date: Thu, 31 Jul 2003 19:02:05 +0000
Subject: efibootmgr 0.4.2-test1
Message-Id: <marc-linux-ia64-105967815211635@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Announcing efibootmgr 0.4.2-test1.  If you have systems you can test
this on, please do so.  It appears to work fine on my BigSur.

* Thu Jul 31 2003 Matt Domsch <Matt_Domsch@dell.com>
- Applied patch from Dann Frazier to enable creating netboot entries.
- update AUTHORS with Dann's netboot contribution.
- Until we can get the ACPI HID and UID programatically, make the user
  pass them in when creating a netboot entry.
- Add O_DIRECT support for reading the disk.
- Fix unparse_hardware_path() for the PCI case - the device and function
  values were printed in reverse order.
- Fix the README file to reflect all the options that can be passed, and
  add a new item for netboot entries.
- whitespace cleanups


If there are no problems with this, I'd like to also fix up the
unaligned access messages that the kernel prints when this creates new
boot entries, but I wanted to clear the plate of this stuff first.

The netboot entries are kind of interesting.  Dann added the -i
<interface> option, but we don't know a programatic way to get ahold of
the ACPI HID and UID information for the device path, so we make the
user pass it in.  That can be removed if we find an automated method for
determining it.  The README gives examples of what to use: 

6) A system administrator wants to create a boot option to network
   boot (PXE).  Unfortunately, this requires knowing a little more
   information about your system than can be easily found by
   efibootmgr, so you've got to pass additional information - the ACPI
   HID and UID values.  These can generally be found by using the EFI
   Boot Manager (in the EFI environment) to create a network boot
   entry, then using efibootmgr to print it verbosely.  Here's one example:
 

     Boot003* Acpi(PNP0A03,0)/PCI(5|0)/Mac(00D0B7F9F510) \
        ACPI(a0341d0,0)PCI(0,5)MAC(00d0b7f9f510,0)
 

   In this case, the ACPI HID is "0A0341d0" and the UID is "0".
   For the zx2000 gigE, the HID is "222F" and the UID is "500".
   For the rx2000 gigE, the HID is "0002" and the UID is "100".
   You create the boot entry with:
   'efibootmgr -c -i eth0 -H 222F -U 500 -L netboot'


For kernels that support O_DIRECT (2.5.x), this should allow us to read
the last sector of an odd-sized disk.  If you can test this, please
report success or failure.



Tarballs at:
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.2-test1.tar.gz
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.2-test1.tar.gz.asc


Feedback welcome!

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

