From: Pat Gefre <pfg@sgi.com>
Date: Tue, 24 Feb 2004 19:16:14 +0000
Subject: Re: [2.6 PATCH] Altix hotplug
Message-Id: <Pine.SGI.3.96.1040224131328.43293F-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040223210448.GA22598@kroah.com>
References: <200402202111.i1KLBp1p027660@fsgi900.americas.sgi.com>
In-Reply-To: <200402202111.i1KLBp1p027660@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Pat Gefre <pfg@sgi.com>, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 23 Feb 2004, Greg KH wrote:

+ On Mon, Feb 23, 2004 at 08:55:14AM -0600, Pat Gefre wrote:
+ > +#define SYSCTL_PCI_UNINITIALIZED	(SYSCTL_PCI_ERROR_BASE - 0)
+ > +    { SYSCTL_PCI_UNINITIALIZED, "module not initialized" },
+ 
+ What are you going to do with this large table of strings?  I see where
+ you copy them to somewhere, but don't see anything beyond that.
+ 
+ Are we missing a huge piece of the puzzle?

Greg,

They are used in sysctl_pci_error_lookup(), which is called
pcibr_slot_pwr(), which is the code to put a device on-line. It all
traces back to the slot_enable call that is made from the hot plug
driver (which is not included in this mod).

-- Pat

