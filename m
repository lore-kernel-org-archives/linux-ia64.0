From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: Tue, 25 Apr 2000 09:29:58 +0000
Subject: Re: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi David,

I get:

Linux version 2.3.99-pre5 (root@ls3020) (gcc version 2.9-ia64-000216 snap-0=
00324) #1 Tue Apr 25 10:01:39 CEST 2000
EFI v0.92 by INTEL AL460GX.86B.0027.D27.021800: SALsystab=3D0x3ff29d60 ACPI=
=3D0x3ffd8f48 MPS=3D0x3ffd0000
SAL v2.112: ia32bios=ABsent, oem=3D, product=3DSAL
sal[0] - entry: pal_proc=3D0x3ff48010, sal_proc=3D0x3fef2080
SAL: Platform features BusLock
args to kernel: memQ2M root=3D/dev/sda2 console=3DttyS0,9600n8
ACPI: INTEL LIONEMU 0.0
      CPU 0 (0000:0000): Available.
IOSAPIC Version 2.1: address 0xfec00000 IRQs 0x0 - 0x3f
      1 CPUs available, 1 CPUs total
ia64_mca_init : begin
ia64_mca_init : registered mca rendezvous spinloop and wakeup mech.
ia64_mca_init : correctable mca vector setup done
ia64_mca_init : registered os mca handler with SAL
ia64_mca_init : os init handler at 53b380
ia64_mca_init : registered os init handler with SAL
ia64_mca_init : platform-specific mca handling setup done
Mca related initialization done
On node 0 totalpages: 65378
zone(0): 65378 pages.
zone(1): 0 pages.
zone(2): 0 pages.
fpswa interface at 3fca4110
SAL/PAL returned: base-freq=99800600, itc-ratio=10/2, proc-ratio=10/2
timer: base freq=100.000MHz, ITC ratio=10/2, ITC freqP0.000MHz
Console: colour VGA+ 80x50
Unexpected irq vector 0x0 on CPU 0!
Lost clock tick on CPU 0 (now=9Eb60ab02, next=9C3d877c3)!!
Calibrating delay loop... 499.71 BogoMIPS
Memory: 1030512k/1046048k available (3148k code, 14592k reserved, 961k data=
, 256k init)
init.c:79: bad pgd 400000000003de00.
Kernel panic: Out of memory.
In idle task - not syncing

with 2.3.99-pre5 + your patch on my Lion. 2.3.52-0419 was fine.

Greetings
		Christoph


