From: Andrew Morton <akpm@osdl.org>
Date: Thu, 08 Apr 2004 07:30:18 +0000
Subject: local symbol 0: discarded in section `.exit.text' from
Message-Id: <20040408003018.42418a33.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


For some reason the ia64 toolchain like to find these...

linux-tiger:/usr/src/25> reference_discarded.pl
Finding objects, 1137 objects, ignoring 0 module(s)
Finding conglomerates, ignoring 119 conglomerate(s)
Scanning objects
Error: ./drivers/scsi/qla2xxx/ql2100.o .debug_info refers to 0000000000011fef DIR64LSB          .exit.text
Error: ./drivers/scsi/qla2xxx/ql2100.o .debug_info refers to 0000000000012310 DIR64LSB          .exitcall.exit
Error: ./drivers/scsi/qla2xxx/ql2100.o .debug_line refers to 000000000000069d DIR64LSB          .exit.text
Error: ./drivers/scsi/qla2xxx/ql2100.o .debug_aranges refers to 0000000000000030 DIR64LSB          .exit.text
Error: ./drivers/scsi/qla2xxx/ql2200.o .debug_info refers to 0000000000011fef DIR64LSB          .exit.text
Error: ./drivers/scsi/qla2xxx/ql2200.o .debug_info refers to 0000000000012310 DIR64LSB          .exitcall.exit
Error: ./drivers/scsi/qla2xxx/ql2200.o .debug_line refers to 000000000000069d DIR64LSB          .exit.text
Error: ./drivers/scsi/qla2xxx/ql2200.o .debug_aranges refers to 0000000000000030 DIR64LSB          .exit.text

Can anyone suggest what has actually caused this to happen?  I have
CONFIG_DEBUG_INFO=n.



Using gcc (GCC) 3.5.0 20040206 (experimental)


Also, I am heartily sick of this gunk from the assembler:

{standard input}:20882: Warning: This is the location of the conflicting usage  {standard input}:20917: Warning: Use of 'ld4' may violate RAW dependency 'DBR#' (data)
{standard input}:20917: Warning: Only the first path encountering the conflict is reported
{standard input}:20882: Warning: This is the location of the conflicting usage
{standard input}:20917: Warning: Use of 'ld4' may violate RAW dependency 'DBR#' (data)

Has that been fixed yet?  If so, which is a good version of binutils to
start using?

Thanks.

