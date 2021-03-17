From: Anatoly Pugachev <matorola@gmail.com>
Date: Wed, 17 Mar 2021 21:58:59 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <CADxRZqx_udmWyfXxeWkMGN+LwND=+QP427oytuLVdHQNVLdL2g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
 <8735wtr2ro.mognet@arm.com> <cf4d7277-54a0-8bc7-60fb-9b2f6befb511@physik.fu-berlin.de>
 <87zgz1pmx4.mognet@arm.com> <20210317211424.33090a37@sf>
In-Reply-To: <20210317211424.33090a37@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: Valentin Schneider <valentin.schneider@arm.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, debian-ia64 <debian-ia64@lists.debian.org>

On Thu, Mar 18, 2021 at 12:42 AM Sergei Trofimovich <slyfox@gentoo.org> wrote:
> > > On 3/17/21 8:36 PM, Valentin Schneider wrote:
> > >> I see ACPI in your boot logs, so I'm guessing you have a bogus SLIT table
> > >> (the ACPI table with node distances). You should be able to double check
> > >> this with something like:
> > >>
> > >> $ acpidump > acpi.dump
> > >> $ acpixtract -a acpi.dump
> > >> $ iasl -d *.dat
> > >> $ cat slit.dsl
> > >
> >
>
> Looking at 'arch/ia64/**' NUMA presence is detected by SRAT ACPI
> tables (and generic ACPI also wants SLIT, those probably exist on large
> ia64 boxes?)

hardware is HPE Integrity BL870c i4 nPar, debian sid/unstable ia64
installed (one of the buildd(s) of debian-ports):

mator@lifshitz:~/acpi$ cat slit.dsl
/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200925 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 *
 * Disassembly of slit.dat, Wed Mar 17 21:52:16 2021
 *
 * ACPI Data Table [SLIT]
 *
 * Format: [HexOffset DecimalOffset ByteLength]  FieldName : FieldValue
 */

[000h 0000   4]                    Signature : "SLIT"    [System
Locality Information Table]
[004h 0004   4]                 Table Length : 0000003C
[008h 0008   1]                     Revision : 01
[009h 0009   1]                     Checksum : 7B
[00Ah 0010   6]                       Oem ID : "HP    "
[010h 0016   8]                 Oem Table ID : "BL860C-4"
[018h 0024   4]                 Oem Revision : 00000001
[01Ch 0028   4]              Asl Compiler ID : "HP  "
[020h 0032   4]        Asl Compiler Revision : 00000001

[024h 0036   8]                   Localities : 0000000000000004
[02Ch 0044   4]                 Locality   0 : 0A FF 14 FF
[030h 0048   4]                 Locality   1 : FF 0A FF FF
[034h 0052   4]                 Locality   2 : 14 FF 0A FF
[038h 0056   4]                 Locality   3 : FF FF FF 0A

Raw Table Data: Length 60 (0x3C)

    0000: 53 4C 49 54 3C 00 00 00 01 7B 48 50 20 20 20 20  // SLIT<....{HP
    0010: 42 4C 38 36 30 43 2D 34 01 00 00 00 48 50 20 20  // BL860C-4....HP
    0020: 01 00 00 00 04 00 00 00 00 00 00 00 0A FF 14 FF  // ................
    0030: FF 0A FF FF 14 FF 0A FF FF FF FF 0A              // ............
