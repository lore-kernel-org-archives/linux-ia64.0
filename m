From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 09 Jun 2004 22:06:29 +0000
Subject: efibootmgr 0.5.0-test4
Message-Id: <20040609220628.GA25010@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

efibootmgr 0.5.0-test4 is now available as a testing version.

http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test4.tar.gz
http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test4.tar.gz.sign

- Fixed bug where read_boot_order() would wrongly return EFI_NOT_FOUND
  when it needed to create a new BootOrder variable.  Reported by
  Micah Parrish.
- Added code to recursively walk the PCI bus putting parent PCI bridges
  in.  This is necessary for Dell PowerEdge 3250 and 7250 servers and
  Intel Tiger2 and Tiger4 platforms when creating PXE boot entries for
  the onboard NICs, and if creating EDD30 boot path entries.  Work by Matt
  and Joshua Giles.
  - Note, efibootmgr now requires libpci for building.


If there are no other issues uncovered, I'd like to release this as
a stable version in another week.


Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
