From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Jun 2004 20:46:49 +0000
Subject: RE: MCA and processors in SAL_BOOT_RENDEZ status
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F015AC4BC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E4BFAF5@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Interesting questions ... 

>Q1: Do they participate in SAL's monarch selection anyway and can
>possibly be the monarch to execute OS_MCA code ? Or they just cannot
>join the RENDEZVOUS and receive INIT later ?

Cpus that were never started by the OS shouldn't be a part of an
MCA rendezvous.

>Q2: the same question w/ the processors in HALT/HALT_LIGHT status.

Once woken, by the OS cpus become part of the system and so will be
rendezvoused for MCA.  PAL_HALT_LIGHT won't change this, I don't think
that PAL_HALT would either.

>Q3: the same question w/ the processors that are logically deconfigured
>from Linux kernel at runtime but the deconfiguration has no report back
>to SAL. In this case, SAL still sees the processor and can select it as
>a monarch to execute OS_MCA which will conflict with Linux kernel.

This is where it gets interesting ... I don't think that there is a
clearly defined way for the OS to deconfigure a processor to prevent
it coming back from the dead after the OS takes it offline.

-Tony
