From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Jun 2003 08:07:18 +0000
Subject: [Linux-ia64] heads up: i/o mmu related changes
Message-Id: <marc-linux-ia64-105590723706202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I justed checked in a changeset
(davidm@tiger.hpl.hp.com|ChangeSet|20030610070955|57077) to make the
kernel work better for machines with I/O MMU.  This should fix the
long-standing bug where IDE disks on machines with memory above 4GB
would MCA if the machine has an I/O MMU.

The trick was to make PCI_DMA_BUS_IS_PHYS a variable which is set at
runtime.  Machines with I/O MMUs or machines with PCI buses which live
in separate address spaces MUST clear this variable.  I updated the
code for the zx1 I/O MMU.  I didn't touch the SGI I/O MMU code,
though, as I wouldn't be able to test it.  Also, it would be good if
someone could test whether IDE disks work fine on machines with
Intel-chipsets and memory above 4GB.

	--david

