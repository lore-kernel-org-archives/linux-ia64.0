From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 10 Nov 2004 11:30:51 +0000
Subject: counting FPSWA faults with pfmon
Message-Id: <1100086251.22456.20.camel@uluru.grenoble.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Certain floating-point programs experience slowdowns
due to excessive floating point traps called "Floating-Point Software
Assist (FPSWA)".

This happens when the hardware cannot complete a floating
point operation and requests help (emulation) from software.
This happens, for instance, with denormals numbers. See
the following document for more details:
   http://www.intel.com/design/itanium/downloads/245415.htm

The symptoms are a slower than normal execution, FPSWA
message in the system log (run dmesg). The average cost of
a FPSWA fault is quite high around 1000 cycles/fault.

By default, the kernel prints a message similar to the
following in the system log:

foo(7716): floating-point assist fault at ip 40000000000200e1
           isr 0000020000000008

The kernel throttles the message in order to avoid flooding
the console.

It is possible to control the behavior of the kernel on FPSWA
faults using the prctl command. In particular, it is possible
to get a signal delivered at the first FPSWA. It is also possible
to silence the console message. However, it is fairly difficult
to figure out just how many faults the program is getting.

Using pfmon and the PMU it is fairly easy to figure how many FPSWA
faults a programs encounters using the following command line:

pfmon -k --drange=fpswa_interface -eloads_retired -- my_test_program

The report number of loads_retired is the number of FPSWA faults:

$ pfmon -k --drange=fpswa_interface -eloads_retired -- test-fpswa
1.90735e-310
                         1 LOADS_RETIRED

The actual results reports the number of time the global pointer
fpswa_interface is loaded into a register. This happens only
once during the processing of a FPSWA fault with any decent
compiler.

It is possible to figure the rate by also collecting the number
of instructions executed:

$ pfmon --no-qual-check -ku --drange=fpswa_interface \
 -eloads_retired,ia64_inst_retired -- test-fpswa

                         1 LOADS_RETIRED
                   2615140 IA64_INST_RETIRED

Hope this is useful.


