From: Ashok Raj <ashok.raj@intel.com>
Date: Mon, 17 May 2004 16:00:03 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040517090002.A6922@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 17, 2004 at 10:38:49AM +0200, Matthias Fouquet-Lapar wrote:
> > But, the story on ppc64 is pretty much that the firmware detects the
> > kinds of hardware failures that we handle, Linux is just notified of it
> > afterword.  
> 
> I think I'm not quite sure why you need hotplug to balance CPUs between
> partitons. (You are not moving physical components for this, right ?)

Don't always equate HOTPLUG with physical removal/addition.

In the above case of balancing between partitions, its a still a hotplug
wrt the kernel, where the cpu is removed from os image (say scheduler etc)
and reintroduce the new resource to another running partition.

Physical removal/addition requires one extra step in addition to what is done
currently, i.e firmware interaction with the OS to handle device arrival and
eject notifications... these mechanisms are often platoform independent, one
example of such a mechanism would be ACPI.

Cheers,
ashok
