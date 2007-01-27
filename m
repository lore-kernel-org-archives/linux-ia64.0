From: Mattia Dongili <malattia@linux.it>
Date: Sat, 27 Jan 2007 13:11:18 +0000
Subject: Re: acpidump vs tiger2
Message-Id: <20070127131118.GB3267@inferi.kami.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200701252320.02765.lenb@kernel.org>
In-Reply-To: <200701252320.02765.lenb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: robert.moore@intel.com, Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Jan 25, 2007 at 11:20:02PM -0500, Len Brown wrote:
> Alexey,
> Using pmtools-20061130 I get some warnings on a Tiger-2:
> 
> [root@tiger lenb]# bin/acpidump >acpidump.out
> acpidump(4538): unaligned access to 0x6000000000008274, ip=0x4000000000002ab1
> acpidump(4538): unaligned access to 0x600000000000827c, ip=0x4000000000002ab1
> 
> Bob,
> acpixtract also results in warnings when running,
> an error in the .dsl file, and inability to re-compile.
[...]
> [lenb@tiger ~]$ head -20 DSDT.dsl
> ACPI Error (nsaccess-0531): ACPI path has too many parent prefixes (^) - reached beyond root node [20061109]

No unaligned access here but I did see this error on another DSDT.

Basically disassembling a DSDT (to fix some errors), rebuilding it,
disassembling again added an External reference at the begininning of
the DSDT DefinitionBlock. If the first rebuild in the above sequence is
performed without optimizations (-oa) everithing is fine. Or eventually
remiving the external ref make re-re-building succeed.

This is the beginning of the diff of the original disassembled and the
optimized disassembled:

  * Original Table Header:
  *     Signature        "DSDT"
- *     Length           0x0000F9A0 (63904)
+ *     Length           0x0000ECCD (60621)
  *     Revision         0x01
  *     OEM ID           "HP    "
  *     OEM Table ID     "nx7400"
  *     OEM Revision     0x00010000 (65536)
- *     Creator ID       "MSFT"
- *     Creator Revision 0x0100000E (16777230)
+ *     Creator ID       "INTL"
+ *     Creator Revision 0x20061109 (537268489)
  */
-DefinitionBlock ("../DSDT.aml", "DSDT", 1, "HP    ", "nx7400", 0x00010000)
+DefinitionBlock ("DSDT.aml", "DSDT", 1, "HP    ", "nx7400", 0x00010000)
 {
-    Name (C000, 0x00)
-    Processor (\_PR.CPU0, 0x01, 0x00001010, 0x06)
+    External (^^^C003.C005.C19C)
+
+    Name (C000, Zero)
+    Processor (_PR.CPU0, 0x01, 0x080C5478, 0x06)
     {

Full DSDT:
http://people.debian.org/~malattia/iasl/DSDT.dat
Some more info about the issue on Debian's BTS:
http://bugs.debian.org/407708

So here's maybe a more clear sequence:

# wget -q http://people.debian.org/~malattia/iasl/DSDT.dat
# wget -q http://people.debian.org/~malattia/iasl/dsdtF0A.patch
# iasl -d DSDT.dat

Intel ACPI Component Architecture
AML Disassembler version 20061109 [Jan 14 2007]
...
Disassembly completed, written to "DSDT.dsl"

# patch -p0 < dsdtF0A.patch
# iasl DSDT.dsl
...
Compilation complete. 0 Errors, 0 Warnings, 0 Remarks, 2153 Optimizations

# iasl -d DSDT.aml
...
Disassembly completed, written to "DSDT.dsl"

# iasl DSDT.dsl | head -n 20

Intel ACPI Component Architecture
ASL Optimizing Compiler version 20061109 [Jan 14 2007]
Copyright (C) 2000 - 2006 Intel Corporation
Supports ACPI Specification Revision 3.0a

ACPI Error (nsaccess-0531): ACPI path has too many parent prefixes (^) - reached beyond root node [20061109]

Maximum error count (200) exceeded
DSDT.dsl    20:     External (^^^C003.C005.C19C)
Error    4014 -         From ACPI CA Subsystem ^  (AE_NOT_FOUND Failure from lookup %s
)

DSDT.dsl    22:     Name (C000, Zero)
Error    4062 -              ^ Object does not exist (C000)

DSDT.dsl    23:     Processor (_PR.CPU0, 0x01, 0x080C5478, 0x06)
Error    4063 -                       ^ Object not found or not accessible from scope (_PR.CPU0)

DSDT.dsl    25:         Name (C001, Zero)

-- 
mattia
:wq!
