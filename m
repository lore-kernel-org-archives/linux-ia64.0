From: Richard Hirst <rhirst@linuxcare.com>
Date: Tue, 12 Mar 2002 20:45:07 +0000
Subject: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905246@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
  Running:

ii  binutils             2.11.93.0.2-2        The GNU assembler, linker and binary utilities.
ii  gcc                  2.96-13              The GNU C compiler.

and building:

ii  parted               1.4.24-1             The GNU Parted disk partition resizing program


I use parted to create GPT tables, which have a partition type GUID
in the first 16 bytes of each table entry.  That entry is being written
offset by one byte, so a partition table entry might look like

0000480  00 a2 a0 d0 eb e5 b9 33 44 87 c0 68 b6 b7 26 99
0000490  83 79 f1 c4 f9 32 46 f7 9a 51 cc 85 c5 d8 a9 68
00004a0  00 28 03 00 00 00 00 00 00 40 06 00 00 00 00 00
00004b0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

instead of

0000480  a2 a0 d0 eb e5 b9 33 44 87 c0 68 b6 b7 26 99 c7
0000490  83 79 f1 c4 f9 32 46 f7 9a 51 cc 85 c5 d8 a9 68
00004a0  00 28 03 00 00 00 00 00 00 40 06 00 00 00 00 00
00004b0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

I've included the relevant bit of code below, along with a disassembly
and a dump of the relevant bit of .rodata.  The significant bit is that
"gpt_part_data->pte->PartitionTypeGuid = PARTITION_BASIC_DATA_GUID" is
implemented as a memcpy(), with a source of .rodata+0xe7, while we can
see in the dump that the guid is actually at .rodata+0xe8.

I've never looked at ia64 asm before today, but I think I've interpreted
it correctly.  This is under debian, but the same corruption has been seen
under RedHat 7.2.

Richard


include/parted/disk_gpt.h:

typedef struct {
        uint32_t time_low;
        uint16_t time_mid;
        uint16_t time_hi_and_version;
        uint8_t  clock_seq_hi_and_reserved;
        uint8_t  clock_seq_low;
        uint8_t  node[6];
} __attribute__ ((packed)) efi_guid_t;

#define PARTITION_BASIC_DATA_GUID \
    ((efi_guid_t) { 0xEBD0A0A2, 0xB9E5, 0x4433, 0x87, 0xC0, { 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7 }})



libparted/fs_ext2/interface.c

        if (strcmp (disk_type->name, GPT_NAME) = 0) {
                GPTPartitionData *gpt_part_data = part->disk_specific;
                PED_ASSERT(gpt_part_data      != NULL, return 0);
                PED_ASSERT(gpt_part_data->pte != NULL, return 0);
                gpt_part_data->pte->PartitionTypeGuid                         PARTITION_BASIC_DATA_GUID;
                {
                        uint8_t *p = (uint8_t *)&gpt_part_data->pte->PartitionTypeGuid;

                        printf("%p: %02x %02x\n", p, p[0], p[1]);
                }
                return 1;
        }



objdump -dr build/libparted/fs_ext2/interface.o:
    1330:       1d 58 01 56 18 10       [MFB]       ld8 r43=[r43]
                        1332: PCREL21B  ped_assert
    1336:       00 00 00 02 00 00                   nop.f 0x0
    133c:       08 00 00 50                         br.call.sptk.many b030 <_ext2_set_system+0x700>;;
    1340:       02 70 00 10 00 21       [MII]       mov r14=r8
    1346:       10 00 8c 00 42 e0                   mov r1=r35;;
    134c:       00 70 18 e6                         cmp4.eq p7,p6=0,r14
    1350:       1c 00 00 00 01 00       [MFB]       nop.m 0x0
    1356:       00 00 00 02 80 03                   nop.f 0x0
    135c:       b0 01 00 43                   (p07) br.cond.dpnt.few 1500 <_ext2_set_system+0x8d0>
    1360:       09 40 01 02 00 24       [MMI]       addl r40=0,r1
                        1360: LTOFF22   .rodata+0xe7
    1366:       70 02 84 30 20 20                   ld8 r39=[r33]       # r39=dst
    136c:       05 01 00 90                         mov r41;;        # r41=cnt
    1370:       1d 40 01 50 18 10       [MFB]       ld8 r40=[r40]       # r40=src, .rodata+0xe7
                        1372: PCREL21B  memcpy
    1376:       00 00 00 02 00 00                   nop.f 0x0
    137c:       08 00 00 50                         br.call.sptk.many b070 <_ext2_set_system+0x740>;;
    1380:       02 40 01 42 18 10       [MII]       ld8 r40=[r33]       # p = gpt_part_data->pte->PartitionTypeGuid
    1386:       10 00 8c 00 42 c0                   mov r1=r35;;
    138c:       01 40 01 84                         mov r14=r40
    1390:       0a 38 01 02 00 24       [MMI]       addl r39=0,r1;;     # printf fmt string
                        1390: LTOFF22   .rodata.str1.8+0x2b0
    1396:       90 0a 38 00 28 00                   ld1 r41=[r14],1     # p[1]
    139c:       00 00 04 00                         nop.i 0x0
    13a0:       0a 38 01 4e 18 10       [MMI]       ld8 r39=[r39];;
    13a6:       a0 02 38 00 20 00                   ld1 r42=[r14]       # p[0]
    13ac:       00 00 04 00                         nop.i 0x0
    13b0:       1d 00 00 00 01 00       [MFB]       nop.m 0x0
                        13b2: PCREL21B  printf
    13b6:       00 00 00 02 00 00                   nop.f 0x0
    13bc:       08 00 00 50                         br.call.sptk.many b0b0 <_ext2_set_system+0x780>;;



objdump -d -j .rodata build/libparted/fs_ext2/interface.o:
...
...
00000000000000b0 <_ext2_fs_h>:
  b0:   24 49 64 3a 20 65 78 74 32 5f 66 73 2e 68 2c 76     $Id: ext2_fs.h,v
  c0:   20 31 2e 33 20 31 39 39 39 2f 31 32 2f 33 31 20      1.3 1999/12/31 
  d0:   30 39 3a 33 36 3a 34 31 20 62 75 79 74 65 6e 68     09:36:41 buytenh
  e0:   20 45 78 70 20 24 00 00 a2 a0 d0 eb e5 b9 33 44      Exp $........3D
  f0:   87 c0 68 b6 b7 26 99 c7                             ..h..&..


