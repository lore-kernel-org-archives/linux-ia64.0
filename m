From: Jack Steiner <steiner@sgi.com>
Date: Fri, 08 Feb 2002 00:56:50 +0000
Subject: Re: [Linux-ia64] anyone maintaining lkcd for ia64?
Message-Id: <marc-linux-ia64-105590698806023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806015@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806015@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> On Thu, Feb 07, 2002 at 02:00:52PM -0600, Jack Steiner wrote:
> > Hi piet
> > 
> > Does the lkcd that you are working on support both SGI SN systems
> > and DIG systems. 
> 
> Most likely.
> 
> > 
> > The main difference is the patch that is required on SGI systems to 
> > support discontiguous memory.
> 
> What patch?

There is a discontig-path on sourceforge. That is the patch that is required
to support SN systems.

If you are developing the code using 2.4.16-product, it should support SN systems.
It may or may not support DIG systems. It depends on whether whether you have
any dependencies on the SN code that is in the tree.


> 
> > Also, we use XSCSI for disk access. Is that an issue??
> 
> Looks like XSCSI isn't configured in n my 2.4.16 workspace:
> 
> 	#
> 	# Alternate SCSI support
> 	#
> 	# CONFIG_XSCSI is not set
> 
> however it appears to have been turned on in the 2.4.16-product gate.
> Sounds like it's a lot faster; does the root partition have to change
> to support XSCSI on the lab machines like monica?

It is marginally faster for most workloads. The question that I have is whether
the lkcd code that writes the dump image will work with XSCSI. If there are
any questions, Jeremy Higdon is the one you need to talk too.

You should probably enable XSCSI in your tree. That way, you will know
for sure whether it will work.

> 
> I think I'll delay upgrading my Workspace till after I check in the
> current lkcd code. If it doesn't handle XSCSI I'll fix it.

When do you expect to do the checkin?? Do you have a TASK for lkcd yet (see
linux.engr->1.6rc1)

> 
> BTW, how are things going on fixing kdb and linux so that breakpoints
> work in 2.4.17? I haven't heard anything on how that's going or the fix 
> for the Machine Checks to non-existing memory that is mapped with the mmu.

Keith Owens should know....


> 
> 
> > Are you working on a pure IA64 patch 
> 
> I believe it's currently pure, I don't think I'm using anything from the sn1
> directory. It's still in development, so we can change things based on
> what come up. 
> 
> To get more work done in parallel it likely better to get working code in
> ASAP to avoid duplication of work.
> 
> -piet
> 
> 
> 
> > > 
> > > On Thu, Feb 07, 2002 at 10:51:26AM -0600, Robert K Gjertsen wrote:
> > > 
> > > Hi Rob:
> > > 
> > > I'm about 90% done on getting a preliminary version of lkcd working
> > > for ia64. I hope to update the workspace shortly. I have to clean up
> > > some of the changes I made to support the dump page size being smaller
> > > that the virtual memory default page size. 
> > > 
> > > I hope to work out a put today with the EFI memory reading by lcrash,
> > > how about I send you a copy tomarrow with some of the code cleaned up and
> > > I'll check it in after I've made sure I haven't brooken ia32.
> > > 
> > > -piet
> > > 
> > > > I've used kdb in the past for ia64, but was
> > > > taking a look at getting lkcd working on RH 7.2
> > > > (2.4.9-18/21) for ia64.
> > > > I grabbed the latest stuff from sourceforge.net
> > > > and I'm working through the patched build now
> > > > and see that dump_base.c is ia64 unfriendly
> > > > with its use of irq_stat (using a hacked patch
> > > > originally from lkcd-2.4.15-1.diff).
> > > > I'm slogging through this, but I hate to reinvent
> > > > the wheel if someone else has a working
> > > > copy/patch (newer kernel version is fine).
> > > > Anyone actually using this for newer kernels
> > > > on ia64 (and has SGI totally dumped working
> > > > on this)?
> > > > 
> > > > Thanks,
> > > > 
> > > > --Rob
> > > > 
> > > > 
> > > > _______________________________________________
> > > > Linux-IA64 mailing list
> > > > Linux-IA64@linuxia64.org
> > > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > > 
> > > _______________________________________________
> > > Linux-IA64 mailing list
> > > Linux-IA64@linuxia64.org
> > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > > 
> > 
> > 
> > -- 
> > Thanks
> > 
> > Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


