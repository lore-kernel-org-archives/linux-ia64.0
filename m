From: Matt_Domsch@Dell.com
Date: Thu, 03 May 2001 03:50:16 +0000
Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005523@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It's not actually clear from the conversation so far what 
> exactly Matt is 
> after.  I get the impression, however, that what he wants to do is 
> synthesise an _HID/_UID pair, which is not quite what's being 
> discussed 
> here.

I'm creating a DEVICE_PATH that looks like ACPI()/PCI()/SCSI()/HardDrive().
I have the PCI bus, device, and function number (via ioctl in kernel 2.4.4)
of the IDE/SCSI/FC/I2O controller, the SCSI ID and LUN, and all the Hard
Drive information.  I'm looking for the ACPI _HID and _UID which match the
controller.

I can cheat somewhat.  I do have the EFI blkX variables, which contain
something like (unparsed):

/proc/efi/vars/blk0-47c7b225-c42a-11d2-8e57-00a0c969723b
Type: 2 Subtype: 1      Length: c
ACPI Device Path: ACPI Device Path
        _HID: a0341d0
        _GID: 1

Type: 1 Subtype: 1      Length: 6
Hardware Device Path: PCI
        Function 0x0, Device 0x2

Type: 3 Subtype: 2      Length: 8
Messaging Device Path: SCSI
        Target ID: 0
        Logical Unit Number: 0

I could look for a device that matches on PCI device,function and SCSI
ID/LUN, and then copy the ACPI Device Path portion, but that still leaves
open the possibility of a PCI device on a separate bus that happens to match
all these fields.

> If that's the case, typically _HID is the 32-bit 
> vendor/device ID of the 
> controller, and _UID is the instance count for the given 
> _HID, eg. the 
> first controller has a _UID of 0, the second has a _UID of 1, etc.

From this example, taken from actual hardware, the _HID is not anything like
the PCI vendor/device ID.  In this case this is a QLogic 12160 PCI SCSI
controller, 0x1077/0x1216.

> > So to get PCI bus number of a given PCI bus:
> > 1. you can use _BBN of the device, but this works only on 
> root pci bridges.

This isn't a bridge, so no luck.

> Because Matt's tool is running in userspace, however, this 
> may not be so 
> easy to achieve.
> 
> > Thus, there seems to be no perfect solutions here... to get 
> > pci bus number from acpi name space alone.
> 
> That's basically correct; you can't do this.

I appreciate the help.  If there isn't a way to do this *today*, what steps
might we take to make this information available in the future?

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux

