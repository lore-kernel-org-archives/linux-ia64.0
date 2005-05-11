From: "Aradhya, Chinmaya Tm (STSD)" <chinmaya@hp.com>
Date: Wed, 11 May 2005 09:52:26 +0000
Subject: gettimeofday() goes backwards
Message-Id: <8BF7471D09AA9B4190A9C96778BC2A1703E81328@qcaexc02.asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On a dual CPU Linux box with kernel version 2.4.9-e.62smp the value
returned by gettimeofday() goes backwards. This problem occurs only on
one of our systems and it doesn't occur on any other with the same
version of the kernel. I noticed this pecuiliar thing on the affected
system - There was too much difference in value of BogoMips b/w the two
processors. I am not sure whether this is related to the descrepency
seen in gettimeofday() o/p. Here is the cpuinfo details of the affected
system. 

processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 5
model name      : Pentium II (Deschutes)
stepping        : 2
cpu MHz         : 449.240
cache size      : 512 KB
physical id     : 0
siblings        : 1
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 mmx fx
sr
bogomips        : 894.56

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 5
model name      : Pentium II (Deschutes)
stepping        : 2
cpu MHz         : 449.240
cache size      : 512 KB
physical id     : 0
siblings        : 1
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 mmx fx
sr
bogomips        : 697.95

Has any one come acrosss this problem and is there a fix for the same.


Thanks
Chinmaya
