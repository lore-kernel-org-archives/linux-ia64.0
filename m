From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 11 Jun 2004 23:19:56 +0000
Subject: Re: MCA and processors in SAL_BOOT_RENDEZ status
Message-Id: <20040611161956.A31762@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 02, 2004 at 01:46:49PM -0700, Luck, Tony wrote:
> Interesting questions ... 
> 
> >Q1: Do they participate in SAL's monarch selection anyway and can
> >possibly be the monarch to execute OS_MCA code ? Or they just cannot
> >join the RENDEZVOUS and receive INIT later ?
> 
> Cpus that were never started by the OS shouldn't be a part of an
> MCA rendezvous.

Correct. Or to be more specific SAL should'nt select them as monarch
since officially OS has not taken control of that CPU.
> 
> >Q2: the same question w/ the processors in HALT/HALT_LIGHT status.
> 
> Once woken, by the OS cpus become part of the system and so will be
> rendezvoused for MCA.  PAL_HALT_LIGHT won't change this, I don't think
> that PAL_HALT would either.
> 
> >Q3: the same question w/ the processors that are logically deconfigured
> >from Linux kernel at runtime but the deconfiguration has no report back
> >to SAL. In this case, SAL still sees the processor and can select it as
> >a monarch to execute OS_MCA which will conflict with Linux kernel.
> 
> This is where it gets interesting ... I don't think that there is a
> clearly defined way for the OS to deconfigure a processor to prevent
> it coming back from the dead after the OS takes it offline.

A first step solution is to put the processor back in BOOT_RENDEZ mode.
which should be the last step to hand off the cpu to SAL.

In the current cpu hotplug code we just spin inside idle thread. 
in arch/ia64/kernel/process.c/play_dead(). Ideally this step
(will) cause a jump to the SAL code, by performing a BIG jump to
br0 saved when the processor was woken into AP mode.

See SAL spec 3.2.5 BR0 holds the return into SAL. If we save enough context
and branch, that would techinically put the processor back in the same mode.

(the above change is under devl for cpu hotplug support)

Cheers,
Ashok Raj
- Linux OS Team
