From: Matt Domsch <Matt_Domsch@dell.com>
Date: Tue, 20 Dec 2005 19:20:19 +0000
Subject: dmi_scan on ia64
Message-Id: <20051220192019.GC21868@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I recently noticed that the IPMI device driver (drivers/char/ipmi) has
converted from using it's own manual parsing of the BIOS-provided DMI
table to find the address of the IPMI controller, and instead now uses
the i386 implementation of arch/i386/kernel/dmi_scan.c.  This of
course broke IPMI device autodetection on x86_64 and ia64 which
weren't using the i386 code.

Andi Kleen worked up a patch (and now I can't find the mail reference
to it) for post-2.6.15 which enables arch/i386/kernel/dmi_scan.c for
x86_64.  It made a generic CONFIG_DMI option which could be set
per-arch for arches that support having DMI tables.  I'd appreciate
it, if/when that hits the tree, that ia64 get similar changes.  I'll
watch for it and try to submit a patch, but wanted others to be on the
lookout too.

Thanks,
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
