From: Pat Gefre <pfg@sgi.com>
Date: Tue, 24 Feb 2004 19:12:14 +0000
Subject: Re: [2.6 PATCH] Altix hotplug
Message-Id: <Pine.SGI.3.96.1040224131106.43293E-100000@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040223202313.GA22207@kroah.com>
References: <200402202111.i1KLBp1p027660@fsgi900.americas.sgi.com>
In-Reply-To: <200402202111.i1KLBp1p027660@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Pat Gefre <pfg@sgi.com>, davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 23 Feb 2004, Greg KH wrote:

+ On Mon, Feb 23, 2004 at 08:55:14AM -0600, Pat Gefre wrote:
+ > 
+ > 2.6 Altix patch for kernel hotplug support
+ 
+ You mean "PCI hotplug support" right?

Yes.


+ 
+ If so, how?  I do not see a single call to pci_hp_register() or friends
+ here.  What is the userspace interface to your pci hotplug system?
+ 

We have a hotplug driver - not included in this update - this is just
the kernel code.

-- Pat

