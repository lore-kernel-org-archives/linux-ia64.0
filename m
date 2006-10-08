From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Sun, 08 Oct 2006 05:40:41 +0000
Subject: RE: Sending cpu 0 back to SAL slave loop
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086ADB@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006203909.GA6500@sgi.com>
In-Reply-To: <20061006203909.GA6500@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jack Steiner [mailto:steiner@sgi.com]
> Sent: 2006=C4=EA10=D4=C27=C8=D5 10:17
> To: Matthew Wilcox
> Cc: Zou, Nanhai; Jay Lan; Luck, Tony; Linux-IA64; fastboot; Eric W. Biede=
rman
> Subject: Re: Sending cpu 0 back to SAL slave loop
>=20
> On Fri, Oct 06, 2006 at 02:44:43PM -0600, Matthew Wilcox wrote:
> > On Fri, Oct 06, 2006 at 03:39:10PM -0500, Jack Steiner wrote:
> > > For kexec, it is ESSENTIAL that all cpus except for the one doing
> > > the kexec be returned to the SAL slave loop. If this is not done, our
> > > chipset will misdirect IO interrupts on the newly exec'ed kernel.
> >
> > Could you do an IPI call to have CPU 0 do the kexec and have the CPU
> > that sent the IPI fall into the SAL slave loop instead?
>=20
> Yes, that seems ok, too. One endcase that must be covered is the
> case where where 1) cpu >0 panics and, 2) cpu 0 is looping with interrupts
> disabled - perhaps waiting on a lock held by the panic'ing cpu.
> In this case, the panic'ing cpu must send an NMI interrupt to cpu 0
> to cause it to do the kexec.  Not sure but I think this can be made to wo=
rk.
>

  This can be done.=20
  Sent an IPI and wait CPU0 to kexec, if CPU0 not response for a certain pe=
riod of time. Send an OS_INIT to force kexec on CPU0. However I wonder shou=
ld we implement it with a kernel-parameter, or make it default behavior?
=20
> Hmmmmm. Another case that is more difficult to handle is a failure
> where an MCA has occurred & cpu 0 is in the SAL rendez slave loop.
> Kexec will have to bring cpu out of the rendez slave loop & cause it
> to kexec the new kernel. Is this possible???
>=20
  Not sure, I can have a try on Tiger, but I guess it depends on the how SA=
L is implementing rendez on each platform.
>=20
> I like the NMI approach for the general case where you are kexec'ing
> a new kernel - not a crashdump kernel. We have some dependencies on
> the boot cpu not changing.
>=20
  For none crashdumping kexec, I have sched_setaffinity code in kexec-tools=
->arch_process_options, so kexec -e will only run on CPU 0.

Thanks
Zou Nan hai
