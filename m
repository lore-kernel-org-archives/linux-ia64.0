From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 06 Dec 2004 16:59:45 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <200412060859.45051.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, December 6, 2004 4:42 am, Hidetoshi Seto wrote:
> Jesse Barnes wrote:
> > On Friday, December 3, 2004 8:31 am, Jesse Barnes wrote:
> >>This patch adds support for sending a SIGBUS to a userspace application
> >>using /proc/bus/pci to drive a device if an I/O error occurs.  We're
> >> using this in house for the X server's BIOS emulator and it seems to be
> >> working well.
> >>
> >>The idea is to track mmaped /proc/bus/pci regions so that the machine
> >> check handler is able to properly determine which process is responsible
> >> for any faults that occur (ia64 is interesting in that the error may not
> >> occur in the process context that actually generated the bad reference).
> >>  If a match is found, a SIGBUS is sent to the process, along with the
> >> address that caused the fault.  The machine check record is then cleared
> >> and recovery takes place (the assumption is that the signal to userspace
> >> is a sufficient record of the error).
>
> Cool!
> BTW I have some short comments.

Does this look a little better?  I've removed the clearing of the error 
records too, in light of Keith's patch to clear them out quickly if they're 
corrected (though I'll need more additions to set the recovered flag 
correctly).

> force_sig_info() takes spinlock in it... I think calling this isn't safe on
> MCA.

This is the only bit I'm unsure about.  I can't just add a spin_trylock 
version, since the call path for send_sig_info calls the slab allocator, 
which takes other locks.

Assuming that only the CPU that caused the MCA is in the MCA handler (i.e. 
rendezvous doesn't occur), then the only time that one of the spinlocks could 
hang is if the current CPU also owned it, right?  Hmm, maybe the 
ia64_spinlock_contention routine could check for a machine check condition 
and promote the failure to an uncorrectable one in that case?  That's pretty 
ugly though...

Jesse
