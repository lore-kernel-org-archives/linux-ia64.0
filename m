From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 12 May 2004 16:15:16 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1084378516.14581.56.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <00cb01c4380b$55c97bc0$39624c0f@india.hp.com>
In-Reply-To: <00cb01c4380b$55c97bc0$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: 'Greg KH' <greg@kroah.com>, Matt_Domsch@dell.com, 'Matthew E Tolentino' <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, 'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>

On Wed, 2004-05-12 at 03:24, Sourav Sen wrote:
> Maybe. But the point I had in mind is, say for example
> memory diagnostics applications/exercisers which reads (Blind
> reads, without caring about contents) memory
> to uncover errors (single bit errors) can use
> this to know the usable ranges and map them thru /dev/mem and
> read those ranges.

If you expose the EFI memory map, then you'll be able to write memory
diagnostics that will work on any EFI-based machine.

If you expose the EFI memory map in an architecture-independent fashion,
then you'll be able to write diagnostics that will work on any *Linux*
machine, plus all of the EFI machines.  Plus, by doing it first, you get
to greatly influence how the arch-independent stuff is done to make your
life the easiest.  

Think /sys/system/devices/memory, not /sys/firmware/efi.

We're planning on doing this anyway for memory hotplug, so some of the
work and ideas are already there.  I'd be happy to point you to some
past discussions and code on the subject.  

-- Dave

