From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2004 05:13:41 +0000
Subject: RE: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

I'm ok with the delete/add of most of the SGI
specific files (maybe it still isn't perfect yet,
but it may be close enough to take it, and then
clean up with some small patches).

But you seem to be touching some files outside of pure SGI
stuff.  These two are a bit of a concern:

  include/asm-ia64/io.h
  arch/ia64/pci/pci.c

These others are outside of my area (well I *might* push
the drivers that are only used by SGI ... but hotplug
and qla1280 are definitely not mine).  So they need to be
split out into separate patches.

  drivers/char/mmtimer.c
  drivers/char/snsc.c
  drivers/ide/pci/sgiioc4.c
  drivers/pci/hotplug/Kconfig
  drivers/scsi/qla1280.c
  drivers/serial/sn_console.c

-Tony
