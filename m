From: Matt_Domsch@Dell.com
Date: Wed, 02 May 2001 19:33:33 +0000
Subject: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm working on a user-space application to add a Linux entry to the IA-64
EFI Boot Manager.  One component of this entry is the ACPI _HID and _UID
fields, which correspond to a PCI bus number (in Linux kernel terms).  I
know the PCI bus number, device, and function, for a given controller.  What
I don't have is the ACPI _HID and _UID fields that match the PCI bus number.
Any thoughts on how I can get them?

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux

