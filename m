From: "H . J . Lu" <hjl@valinux.com>
Date: Sun, 10 Sep 2000 19:25:24 +0000
Subject: [Linux-ia64] More on B1 BigSur and test8 kernel
Message-Id: <marc-linux-ia64-105590678205482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 09, 2000 at 05:17:12PM -0700, David Mosberger wrote:
> >>>>> On Sat, 9 Sep 2000 14:49:52 -0700, "H . J . Lu" <hjl@valinux.com> said:
> 
>   HJ> Yes, I did "make dep". What should include/asm-ia64/offsets.h
>   HJ> look like? That may explain many things.
> 
> Well, it depends on your kernel configuration.  If you did a "make
> dep", you should have the right values in there.
> 
> I'm not sure why the new kernel isn't working for you.  Nothing has
> changed in the kernel that would explain an infinite stream of irq 0.
> 

More info on my UP BigSur with B1 stepping and BIOS Build 59:

1.  The kernel from TurboLinux 0828 boots and prints out

ACPI: Intel    RSDT   0.0
Acpi cfg:bind to Boot time Acpi OSD
Acpi cfg:acpi initialize pass
Acpi cfg:acpi load firmware tables pass
Acpi cfg:acpi load namespace pass
      CPU 0 (0000:0000): Available.
IOSAPIC Version 2.1: address 0xfec00000 IRQs 0x0 - 0x3f
Acpi cfg:get pci vectors 
Acpi cfg:_STA not found: pci bus 0 exist 
Acpi cfg:_STA not found: pci bus 1 exist 
Acpi cfg:_STA not found: pci bus 2 exist 
Acpi cfg:_STA not found: pci bus 3 exist 
      1 CPUs available, 1 CPUs total
ACPI:         -0550: <7>ACPI: *** Success: Entire namespace and objects deleted
Acpi cfg:acpi terminate pass
Acpi cfg:bind to Run time Acpi OSD
ia64_mca_init : begin
ia64_mca_init : registered mca rendezvous spinloop and wakeup mech.
ia64_mca_init : correctable mca vector setup done
ia64_mca_init : registered os mca handler with SAL
ia64_mca_init : os init handler at 5414b0
ia64_mca_init : registered os init handler with SAL
ia64_mca_init : platform-specific mca handling setup done
Mca related initialization done
On node 0 totalpages: 64672
zone(0): 64672 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Placing software IO TLB between 0xe000000000100000 - 0xe000000000300000
Kernel command line: root=/dev/sda2 init=/bin/bash
fpswa interface at 3f197010
timer: CPU 0 base freq3.344MHz, ITC ratio/2, ITC freqf6.722MHz
Console: colour VGA+ 80x25
Unexpected irq vector 0x0 on CPU 0!
Calibrating delay loop... 545.26 BogoMIPS


2. The test8 kernel + David's ia64 patch + my 2 patches + comment out

Unexpected irq vector 0x0 on CPU 0!

compiled on my BigSur with 0825 RedHat ia64 running TurboLinux 0828
kernel. I get

ACPI: Intel    RSDT   0.0
Acpi cfg:bind to Boot time Acpi OSD
Acpi cfg:acpi initialize pass
Acpi cfg:acpi load firmware tables pass
Acpi cfg:acpi load namespace pass
      CPU 0 (0000:0000): Available.
IOSAPIC Version 2.1: address 0xfec00000 IRQs 0x0 - 0x3f
Acpi cfg:get pci vectors 
Acpi cfg:_STA not found: pci bus 0 exist 
Acpi cfg:_STA not found: pci bus 1 exist 
Acpi cfg:_STA not found: pci bus 2 exist 

If I leave

Unexpected irq vector 0x0 on CPU 0!

in, I get a stream of 

Unexpected irq vector 0x0 on CPU 0!

and machin locks up.

3. The test8 kernel + David's ia64 patch +  my 2 patches + comment out

Unexpected irq vector 0x0 on CPU 0!

cross compiled on ia32 with the 0828 snapshot, I get

ACPI: Intel    RSDT   0.0
Acpi cfg:bind to Boot time Acpi OSD
Acpi cfg:acpi initialize pass
Acpi cfg:acpi load firmware tables pass
ACPI:	-0542 <7>ACPI: *** Warning: Type misatch
swapper[0]: General Exception: ......
.....

and machine locks up.

4. The test8 kernel + David's ia64 patch +  my 2 patches cross compiled
 on ia32 with the 0828 snapshot, I get

ACPI: Intel    RSDT   0.0
Acpi cfg:bind to Boot time Acpi OSD
Acpi cfg:acpi initialize pass
Unexpected irq vector 0x0 on CPU 0!pass
Calibrating delay loop... 545.26 BogoMIPS
.....

Then later I get SCSI timeout since QLA1280 gets IRQ 3.

I have no idea if it is a hardware, compiler or kernel ACPI bug. Is
it possible that

Unexpected irq vector 0x0 on CPU 0!

comes at the wrong time which screws up the ACPI parsing. That may
explain why only TurnboLinux's kernel works on my B1 BigSur.

Thanks.

-- 
H.J. Lu (hjl@gnu.org)

