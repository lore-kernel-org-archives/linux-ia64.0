From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 06 May 2004 14:00:40 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1083852039.2811.55.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
	 <20040506114414.A14543@infradead.org>
	 <20040506115919.GZ2281@parcelfarce.linux.theplanet.co.uk>
	 <1083845904.3844.2.camel@laptop.fenrus.com>
	 <20040506132711.GA2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040506132711.GA2281@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Arjan van de Ven <arjanv@redhat.com>, Christoph Hellwig <hch@infradead.org>, Sourav Sen <souravs@india.hp.com>, Matt_Domsch@dell.com, Matthew E Tolentino <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 2004-05-06 at 06:27, Matthew Wilcox wrote:
> On Thu, May 06, 2004 at 02:18:24PM +0200, Arjan van de Ven wrote:
> > On Thu, 2004-05-06 at 13:59, Matthew Wilcox wrote:
> > > It's not exactly modifiable. 
> > 
> > come on, it's the ideal hotplug memory interface ;)
> > should we try to unify the memory map exports between architectures
> > instead of matching the firmware-of-the-day for each architecture ??
> 
> Well, firmware-du-jour is what /sys/firmware/... is for ;-)
> 
> I don't have a clear picture of what a hotplug memory interface would look
> like; and even if I did, I don't think the EFI memory map is of much help
> in that matter.

If you _get_ a clear picture, please let me know.  I've been looking for
one. :)

You're right that the EFI map itself isn't any help to memory hotplug,
but things derived from it are.  The amount and physical locations of
all of the memory in the system are obviously pulled out of this table
at some point, and Linux already has a representation of them, otherwise
we couldn't allocate memory or do things like virt_to_phys() or
page_to_pfn().

I think what Arjan doesn't want is 14 different architectures with 14
different userspace programs reading 14 different things in /proc and
/sys for each of their memory hotplug schemes.  I guarantee you don't
want to know what ppc64 is planning on doing.

BTW, Sourav, what is it that you need from the EFI map?  Could you take
a quick look through the lhms-devel list archives and see if anything
there is similar to what you're trying to do? Here's a place to start:

http://sourceforge.net/mailarchive/forum.php?thread_idA20609&forum_id"3


-- Dave

