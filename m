From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 19 May 2001 03:45:27 +0000
Subject: [Linux-ia64] Buggy unwind tables in user space
Message-Id: <marc-linux-ia64-105590693005627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Most IA64 distributions contain a bad version of crtn.o.  Executables
or shared libraries built with this file have invalid unwind data.

SuSe Linux 7.1a, TurboLinux 000828, TL 010307 (beta3) and Redhat 7.0.90
all have a buggy version of crtn.o.  Redhat 7.0.98 (Wolverine) has a
clean version of crtn.o, but if any Wolverine binaries were compiled
against the old crtn.o then they will be bad as well.

# objdump -r -j .IA_64.unwind /usr/lib/crt?.o

/usr/lib/crt1.o:     file format elf64-ia64-little

RELOCATION RECORDS FOR [.IA_64.unwind]:
OFFSET           TYPE              VALUE 
0000000000000000 SEGREL64LSB       .text
0000000000000008 SEGREL64LSB       .text+0x0000000000000080
0000000000000010 SEGREL64LSB       .IA_64.unwind_info

/usr/lib/crti.o:     file format elf64-ia64-little

RELOCATION RECORDS FOR [.IA_64.unwind]:
OFFSET           TYPE              VALUE 
0000000000000000 SEGREL64LSB       .init
0000000000000008 SEGREL64LSB       .init+0x0000000000000060
0000000000000010 SEGREL64LSB       .IA_64.unwind_info
0000000000000018 SEGREL64LSB       .fini
0000000000000020 SEGREL64LSB       .fini+0x0000000000000020
0000000000000028 SEGREL64LSB       .IA_64.unwind_info+0x0000000000000010

/usr/lib/crtn.o:     file format elf64-ia64-little

RELOCATION RECORDS FOR [.IA_64.unwind]:
OFFSET           TYPE              VALUE 
0000000000000008 SEGREL64LSB       .init+0x0000000000000020
0000000000000010 SEGREL64LSB       .IA_64.unwind_info
0000000000000020 SEGREL64LSB       .fini+0x0000000000000020
0000000000000028 SEGREL64LSB       .IA_64.unwind_info+0x0000000000000010

crtn.o relocation records are wrong.  Offsets 0 and 18 have no
relocation entries so they end up as zero.  Typical executable dump

Hex dump of section '.IA_64.unwind':
  0x4000000000000990 00000000 00000400 00000000 00000000
  0x40000000000009a0 00000000 00000000 00000000 00000900
  0x40000000000009b0 00000000 00000910 00000000 00000860
  0x40000000000009c0 00000000 00000350 00000000 000002f0
  0x40000000000009d0 00000000 000004a0 00000000 00000880

The first three entries are
  start   end     info
  0x0000  0x0400  0x0900 - bad
  0x0000  0x0860  0x0910 - bad
  0x02f0  0x0350  0x0880 - good


