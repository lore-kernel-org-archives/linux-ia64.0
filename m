From: "Sourav Sen" <souravs@india.hp.com>
Date: Thu, 06 May 2004 13:32:07 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <004801c4336c$daae5840$39624c0f@india.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040506124649.GA13482@lists.us.dell.com>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Matt Domsch' <Matt_Domsch@dell.com>, 'Sourav Sen' <souravs@india.hp.com>
Cc: matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com

Hi Matt,

+ -----Original Message-----
+ From: Matt Domsch [mailto:Matt_Domsch@dell.com]
+ On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
+ > The following simple patch creates a read-only file
+ > "memmap" under <mount point>/firmware/efi/ in sysfs
+ > and exposes the efi memory map thru it.
+ 
+ I'm not generally opposed, but have a couple questions.
+ 
+ 1) Why does userspace / humans need to know this?  For 
+ debugging firmware?
	
	Maybe. But the point I had in mind is, say for example
memory diagnostics applications/exercisers which reads (Blind
reads, without caring about contents) memory
to uncover errors (single bit errors)  can use
this to know the usable ranges and map them thru /dev/mem and
read those ranges.

+ 
+ 2) Can the memory map output ever be larger than PAGE_SIZE (lower
+ limit is 4KB on x86)?  If not, what guarantees that?  If so, you need
+ your own read mechanism rather than the generic sysfs one.
+ 

	I don't have an answer right now. I'll investigate. Tony Luck also 
expressed similar concerns and suggested seq*() interfaces. I'll see
how I can do that.

+ The one-value-per-file rule has an exception for an array of values of
+ the same type per Documentation/filesystems/sysfs.txt, which this
+ looks to adhere to.
+ 
+ Thanks,
+ Matt
+ 
+ -- 
+ Matt Domsch
+ Sr. Software Engineer, Lead Engineer
+ Dell Linux Solutions linux.dell.com & www.dell.com/linux
+ Linux on Dell mailing lists @ http://lists.us.dell.com
+ 

Thanks
Sourav
