From: Keith Owens <kaos@sgi.com>
Date: Thu, 06 Nov 2003 12:34:13 +0000
Subject: Re: [PATCH] salinfo for 2.6.0-test9
Message-Id: <marc-linux-ia64-106812211114449@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106812011912671@msgid-missing>
In-Reply-To: <marc-linux-ia64-106812011912671@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 06 Nov 2003 20:57:26 +0900, 
Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:
>Here is my loose patch porting 2.4.22 salinfo to 2.6.0-test9.

salinfo has been completely redone in 2.4.23-pre9, the 2.4.22 version
of salinfo had races and deadlocks for all record types, it was not
safe for MCA/INIT processing and could break the MCA/INIT code in
mca.c.  Please do not update salinfo in 2.6 until Bjorn gets back and
we work out the last few patches to salinfo in 2.4.

I am also rewriting user space salinfo to decode much more data, for
example


BEGIN HARDWARE ERROR STATE from /var/log/salinfo/raw/2003-10-23_01:45:07_cpu0_mca
Err Record ID: 0    SAL Rev:  0.02
Time: 10/23/2003 01:41:14    Severity 0
Processor Device Error Info Section
  EXTERNAL BUS ERROR: Bus Check
    processor lid            : 0x0000000000000000
      cpu: A nasid: 0x0
    processor state parameter: 0x20000000fff211a0
      rendezvous request unsuccessful
      rendezvous was not attempted
      min state registered with PAL
      storage integrity not synchronized
      continuable
      machine check is isolated
      more info available
      ip logged is not precise
      min state is not precise
      processor dynamic state is not valid
      fault has not been corrected
      bus check
      PAL recovery status:
        error was isolated and contained, continuable if sw can recover
    processor error map      : 0x0000000001000000
      processor code id: 0
      logical thread id: 0
      processor bus level 1 error
  BUS Check Info [0]
    Transaction size: 0, External Bus Error:, Type: 0 (Unknown/unclassified), Severity: 0, Hierarchy: 0, Status information: 1 (Berr)
  CPUID Regs: 0x49656e69756e6547 0x6c65746e 0 0x1f000604
  
  Processor static data:
    xip  : 0xe000000004415f60  xfs  : 0x800000000000058c
    xpsr : 0x0000121008026018
                [0:5] User mask: 24
            be  [1] 0 little endian
            up  [2] 0 user performance monitor disabled
            ac  [3] 1 alignment check enabled
            mfl [4] 1 lower (f2 .. f31) floating-point registers written
            mfh [5] 0 upper (f32 .. f127) floating-point registers not written
                [0:23] System mask: 155672
            ic  [13] 1 interrupt collection enabled
            i   [14] 1 interrupts enabled
            pk  [15] 0 protection key disabled
            dt  [17] 1 data address translation enabled
            dfl [18] 0 disabled floating-point low register not set
            dfh [19] 0 disabled floating-point high register not set
            sp  [20] 0 secure performance monitor disabled
            pp  [21] 0 privileged performance monitor disabled
            di  [22] 0 disable instruction set transition not set
            si  [23] 0 secure interval timer disabled
            db  [24] 0 debug breakpoint fault disabled
            lp  [25] 0 lower privilege transfer trap disabled
            tb  [26] 0 taken branch trap disabled
            rt  [27] 1 register stack translation enabled
            cpl [32:33] current privilege level: 0
            is  [34] 0 IA64 instruction set
            mc  [35] 0 machine check abort enabled
            it  [36] 1 instruction address translation enabled
            id  [37] 0 instruction debug fault enabled
            da  [38] 0 enable data access and dirty-bit faults
            dd  [39] 0 data debug fault enabled
            ss  [40] 0 single step disabled
            ri  [41:42] restart instruction: 1
            ed  [43] 0 exception deferral disabled
            bn  [44] 1 bank 1
            ia  [45] 0 instruction access-bit faults enabled

