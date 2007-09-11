From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 Sep 2007 23:14:56 +0000
Subject: [RFC] module to support ACPI AML calls to native firmware
Message-Id: <200709111714.57095.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

Here are a couple patches on which I'd like some feedback.

The basic idea is that ACPI AML methods sometimes need to do something
that is already implemented as a SAL interface.  ACPI doesn't provide a
way for an AML method to directly call the SAL interface.  That means
firmware writers sometimes have to implement things twice: once in SAL,
then again in AML, which leads to duplication and errors.

So HP dreamed up a way to reduce this duplication by connecting AML with
native firmware by using an ACPI Operation Region.  HP firmware uses this
for some hotplug functionality.  So far, we have not had a Linux driver
for this OpRegion, so we haven't been able to take advantage of this
hotplug functionality.

These patches implement this OpRegion driver.  The OpRegion is connected
to an HPQ5001 ACPI device, so it's only useful on HP systems.  Therefore,
I'd like to make it a module so non-HP systems are not penalized by the
4K or so of space the driver uses.

The driver needs to serialize firmware calls using the sal_lock.  That
lock is currently not exported, which prevents making the driver a
module.  We could easily rectify that by exporting sal_lock (this would
also enable making arch/ia64/kernel/esi.c a module), but there was some
resistance to that in the past.

So I'm interested in feedback on the following patches, which do not
export sal_lock, but rather export functions that can be used to call
SAL or other native firmware interfaces.

Bjorn
