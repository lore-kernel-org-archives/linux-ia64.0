From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 15 Jun 2004 16:17:33 +0000
Subject: Re: MCA and processors in SAL_BOOT_RENDEZ status
Message-Id: <20040615091732.A10389@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 14, 2004 at 06:01:08PM -0700, John Lee wrote:
> 
>    >> >Q1: Do they participate in SAL's monarch selection anyway and can
>    >>  >possibly  be  the  monarch  to execute OS_MCA code ? Or they just
>    cannot
>    >> >join the RENDEZVOUS and receive INIT later ?
>    >>
>    >> Cpus that were never started by the OS shouldn't be a part of an
>    >> MCA rendezvous.
>    >
>    >Correct. Or to be more specific SAL should'nt select them as monarch
>    >since officially OS has not taken control of that CPU.
> 
> 
>    Is this because they are still in BOOT_RENDEZV state ?
>    These CPUs are guaranteed not to participate in MCA processing?
>    How does SAL tell them from CPUs under Linux in monarch selection?

SAL knows which processors are in OS control, since it also processes the wakeup
vector when OS sends a wakeup to wakeup the CPU. The wakeup vector is 
obtained from the sal tables via efi vars.

> 
>    >>  >Q3:  the  same  question  w/  the  processors  that are logically
>    deconfigured
>    mode.
>    What  if  the  processor  logically deconfigured from Linux is not put
>    back in BOOT_RENDEZV but is running its own independent code ? I think
>    global  MCA  can come thru the processor. Is there any way to make SAL
>    not choose the processor for global MCAs - for example, a SAL call for
>    Linux  to  call  to specify disqualified processors to reflect Linux's
>    logical view?


Humm, just curious, is this because you are trying to use this one cpu for some other 
processing outside of kernel resources, say for dedicated processing something...

I dont know of the top of my head, i will let you know once i find out.


-
Cheers,
Ashok Raj
- Linux OS Technologies Team
