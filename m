From: Jack Steiner <steiner@sgi.com>
Date: Fri, 06 Oct 2006 20:39:10 +0000
Subject: Re: Sending cpu 0 back to SAL slave loop
Message-Id: <20061006203909.GA6500@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 12, 2006 at 04:25:34PM -0500, Jack Steiner wrote:
> On Tue, Sep 12, 2006 at 01:23:54PM -0700, Luck, Tony wrote:
> > > Hmmm. I may have answered at least part of my question. It appears that the boot cpu
> > > cannot exit back to the SAL slave loop since it was never in the slave loop to start with.
> > >
> > > This will take some thought..... More later.
> > 
> > Yes.  cpu0 is a special case as there is no way to return it to SAL.
> > Linux hotplug code has a hack where we borrow the return details from
> > some other cpu in the case that someone wants to take cpu0 offline.
> > Will this work for Altix?  Would we have to be careful to get the
> > return details from some other cpu on the same node?
> > 
> > -Tony
> 
> Interesting idea. We might be able to make this work. It looks like we
> need to make some changes to our BIOS to make this work but it looks
> possible.
> 
> I'll investigate this some more.....
> 



(Sorry for taking so long to respond - vacation :-) & too much work)


I took another look at the SN issues involved in trying to send the boot
cpu back to the SAL slave loop during kexec. As others have pointed out,
the boot cpu was never in the slave loop so simply returning back to SAL
is not possible because the return address for cpu 0 (B0) does not point
to the SAL slave loop.

The HOTPLUG code added a hack to copy B0 from cpu 1
sal_boot_rendez_state[1].b0 to cpu  0 sal_boot_rendez_state area[0].b0.
This works only if the SAL slave loop is a simple assembly language
routine that does not use the RSE, SP, preserved registers, etc.

This is not true for the current SN BIOS. The SN SAL slave loop consists
of multiple functions written in both C & assembly. Sending cpu 0 back to
the SAL slave loop requires that the general registers & RSE area be
"fixed" as well. This is not possible for the general case since the state
could contain data such as stack pointers.

Fortunately, the changes to recode the slave loop as pure assembly appear
to be minimal & we plan to make these changes. The only hardspot is that
the slave loop adddress is not guaranteed to be the same if cpu0 & cpu1
are on different nodes & the nodes are running different versions of the
BIOS. Mixed BIOS versions is not a configuration that customers run so we
can ignore this problem - at least for now.  (We should try to detect
mixed BIOS versions & disable sending the boot cpu back to the slave
loop). 

Long term IA64 should implement an architected method for returning the
boot cpu to the SAL slave loop. Perhaps a new SAL call could do this.


For kexec, it is ESSENTIAL that all cpus except for the one doing
the kexec be returned to the SAL slave loop. If this is not done, our
chipset will misdirect IO interrupts on the newly exec'ed kernel.



-- jack
