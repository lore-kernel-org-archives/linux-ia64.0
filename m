From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2004 16:44:26 +0000
Subject: Re: [Fastboot] Re: [BROKEN PATCH] kexec for ia64
Message-Id: <m14qnhilg5.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
	<200407261536.05133.jbarnes@engr.sgi.com>
	<20040730155504.2a51b1fa.rddunlap@osdl.org>
	<m18ycvhx1j.fsf@ebiederm.dsl.xmission.com>
	<20040804233335.GD548@cup.hp.com>
	<m1hdri2uw0.fsf@ebiederm.dsl.xmission.com>
	<20040805153929.GC6526@cup.hp.com>
In-Reply-To: <20040805153929.GC6526@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, linux-ia64@vger.kernel.org, fastboot@osdl.org, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org

Grant Grundler <iod00d@hp.com> writes:

> On Wed, Aug 04, 2004 at 08:14:55PM -0600, Eric W. Biederman wrote:

> > In the general case it appears to be overkill, incorrect and
> > insufficient to disable bus mastering on all PCI devices.  Which is
> > why device_shutdown() calls device specific code.
> 
> Is anyone else considering using kexec() to recover from a oops/panic?

Yes.  That is what most of the recent discussion was about.  Considering
this was one of the subjects brought up at the kernel summit I'm surprised
a lot of people have been thinking that way.

> What is the risk calling multiple device_shutdown() will expose another panic?

It has been agreed that device_shutdown() will not be called in the panic
path.  What gets called on panic or other fatal case is going to be
a streamlined code path, that is little more than a jump to the
previously loaded kernel.  

> While calling a device specific cleanup is best, I worry about how
> much code/data gets touched in this path. I was hoping something
> simple like twiddling bus master bit would be sufficient.
> If it's not, oh well.

The kernel on the other side of the kexec gets to do this.  It will
run out of memory reserved for it in the kernel that panic'd since
boot time.

That is not perfect protection but it simple and quite good.
Especially with the addition of verifying a hash of the new kernel
before it messes with the hardware.  (But that code gets to live
in /sbin/kexec and added as a prefix to the recovery kernel)

I don't expect that is enough to give a full recovery but it
should be sufficient to take a core dump of the system or
do any number of other interesting things.  But before
running a full kernel it is expected that the entire system will
be reset, to get everything back into a sane state.

And of course all of this is largely architecture independent
so that the basic code should work on any architecture.

Eric
