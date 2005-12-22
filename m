From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 22 Dec 2005 20:50:23 +0000
Subject: Re: [PATCH 0/3] msi abstractions and support for altix
Message-Id: <20051222205023.GK2361@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222201651.2019.37913.96422@lnx-maule.americas.sgi.com> <20051222202259.GA4959@suse.de> <20051222202627.GI17552@sgi.com> <20051222203415.GA28240@suse.de> <20051222203824.GJ17552@sgi.com>
In-Reply-To: <20051222203824.GJ17552@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Greg KH <gregkh@suse.de>, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thu, Dec 22, 2005 at 02:38:24PM -0600, Mark Maule wrote:
> Because on ia64 IA64_FIRST_DEVICE_VECTOR and IA64_LAST_DEVICE_VECTOR
> (from which MSI FIRST_DEVICE_VECTOR/LAST_DEVICE_VECTOR are derived) are not
> constants.  The are now global variables (see change to asm-ia64/hw_irq.h)
> to allow the platform to override them.  Altix uses a reduced range of
> vectors for devices, and this change was necessary to make assign_irq_vector()
> to work on altix.

To be honest, I think this is just adding a third layer of paper over
the crack in the wall.  The original code assumed x86; the ia64 port
added enough emulation to make it look like x86 and now altix fixes a
couple of assumptions.  I say: bleh.

What we actually need is an interface provided by the architecture that
allocates a new irq.  I have a hankering to implement MSI on PA-RISC but
haven't found the time ... 
