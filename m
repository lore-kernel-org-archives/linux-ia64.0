From: Pat Erley <pat-lkml@erley.org>
Date: Tue, 13 Oct 2015 04:06:41 +0000
Subject: Re: [Linaro-acpi] [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <561C8351.3030304@erley.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020400020909000807060404"
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
 <560BA4C9.7090607@huawei.com> <560C0968.6020904@redhat.com>
 <2808057.teMg2oCLf6@vostro.rjw.lan> <5612AF64.4060900@redhat.com>
 <561B2442.9050600@erley.org> <561B2DAD.5070601@linaro.org>
 <561B2FCA.1010504@erley.org> <561C1D87.8010106@linaro.org>
In-Reply-To: <561C1D87.8010106@linaro.org>
To: Al Stone <al.stone@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Al Stone <ahs3@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, patches@linaro.org, Hanjun Guo <guohanjun@huawei.com>, linux-arm-kernel@lists.infradead.org

This is a multi-part message in MIME format.
--------------020400020909000807060404
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 10/12/2015 01:52 PM, Al Stone wrote:
> On 10/11/2015 09:58 PM, Pat Erley wrote:
>> On 10/11/2015 08:49 PM, Hanjun Guo wrote:
>>> On 10/12/2015 11:08 AM, Pat Erley wrote:
>>>> On 10/05/2015 10:12 AM, Al Stone wrote:
>>>>> On 10/05/2015 07:39 AM, Rafael J. Wysocki wrote:
>>>>>> On Wednesday, September 30, 2015 10:10:16 AM Al Stone wrote:
>>>>>>> On 09/30/2015 03:00 AM, Hanjun Guo wrote:
>>>>>>>> On 2015/9/30 7:45, Al Stone wrote:
>>>>>>>>> NB: this patch set is for use against the linux-pm bleeding edge
>>>>>>>>> branch.
>>>>>>>>>
>>>>>>>
>>>>>>> [snip...]
>>>>>>>
>>>>>>>>
>>>>>>>> For this patch set,
>>>>>>>>
>>>>>>>> Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
>>>>>>>>
>>>>>>>> Thanks
>>>>>>>> Hanjun
>>>>>>>
>>>>>>> Thanks, Hanjun!
>>>>>>
>>>>>> Series applied, thanks!
>>>>>>
>>>>>> Rafael
>>>>>>
>>>>>
>>>>> Thanks, Rafael!
>>>>>
>>>>
>>>> Just decided to test out linux-next (to see the new nouveau cleanups).
>>>> This change set prevents my Lenovo W510 from booting properly.
>>>>
>>>> Reverting: 7494b0 "ACPI: add in a bad_madt_entry() function to
>>>> eventually replace the macro"
>>>>
>>>> Gets the system booting again.  I'm attaching my dmesg from the failed
>>>> boot, who wants the acpidump?
>>>
>>> [    0.000000] ACPI: undefined version for either FADT 4.0 or MADT 1
>>> [    0.000000] ACPI: Error parsing LAPIC address override entry
>>> [    0.000000] ACPI: Invalid BIOS MADT, disabling ACPI
>>>
>>> Seems the MADT revision is not right, could you dump the ACPI MADT
>>> (APIC) table and send it out? I will take a look :)
>>>
>>> Thanks
>>> Hanjun
>>
>> Here ya go, enjoy.  Feel free to CC me on any patches that might fix it.
>
> Pat,
>
> Would you mind sending a copy of the FADT, also, please?  The first of the
> ACPI messages is a check of version correspondence between the FADT and MADT,
> while the second message is from looking at just an MADT subtable.  Thanks
> for sending the MADT out -- that helps me quite a lot in thinking this through.
>
> BTW, whoever is providing the BIOS (Lenovo, I assume) may want to have a look
> at these, also:
>
> [    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in
> FADT/Pm1aControlBlock: 16/32 (20150818/tbfadt-623)
> [    0.000000] ACPI BIOS Warning (bug): Invalid length for
> FADT/Pm1aControlBlock: 32, using default 16 (20150818/tbfadt-704)
>
> Not inherently dangerous, but definitely sloppy and mind-numbingly easy to
> avoid, IIRC.
>

Here ya go.

--------------020400020909000807060404
Content-Type: text/x-dsl;
 name="facp.dsl"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="facp.dsl"

/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20150717-64
 * Copyright (c) 2000 - 2015 Intel Corporation
 * 
 * Disassembly of facp.dat, Mon Oct 12 21:06:03 2015
 *
 * ACPI Data Table [FACP]
 *
 * Format: [HexOffset DecimalOffset ByteLength]  FieldName : FieldValue
 */

[000h 0000   4]                    Signature : "FACP"    [Fixed ACPI Description Table (FADT)]
[004h 0004   4]                 Table Length : 000000F4
[008h 0008   1]                     Revision : 04
[009h 0009   1]                     Checksum : 59
[00Ah 0010   6]                       Oem ID : "LENOVO"
[010h 0016   8]                 Oem Table ID : "TP-6N   "
[018h 0024   4]                 Oem Revision : 00001450
[01Ch 0028   4]              Asl Compiler ID : "LNVO"
[020h 0032   4]        Asl Compiler Revision : 00000001

[024h 0036   4]                 FACS Address : BBEE7000
[028h 0040   4]                 DSDT Address : BBFF1C9B
[02Ch 0044   1]                        Model : 00
[02Dh 0045   1]                   PM Profile : 02 [Mobile]
[02Eh 0046   2]                SCI Interrupt : 0009
[030h 0048   4]             SMI Command Port : 000000B2
[034h 0052   1]            ACPI Enable Value : F0
[035h 0053   1]           ACPI Disable Value : F1
[036h 0054   1]               S4BIOS Command : 00
[037h 0055   1]              P-State Control : 80
[038h 0056   4]     PM1A Event Block Address : 00001000
[03Ch 0060   4]     PM1B Event Block Address : 00000000
[040h 0064   4]   PM1A Control Block Address : 00001004
[044h 0068   4]   PM1B Control Block Address : 00000000
[048h 0072   4]    PM2 Control Block Address : 00001050
[04Ch 0076   4]       PM Timer Block Address : 00001008
[050h 0080   4]           GPE0 Block Address : 00001020
[054h 0084   4]           GPE1 Block Address : 00000000
[058h 0088   1]       PM1 Event Block Length : 04
[059h 0089   1]     PM1 Control Block Length : 02
[05Ah 0090   1]     PM2 Control Block Length : 01
[05Bh 0091   1]        PM Timer Block Length : 04
[05Ch 0092   1]            GPE0 Block Length : 10
[05Dh 0093   1]            GPE1 Block Length : 00
[05Eh 0094   1]             GPE1 Base Offset : 00
[05Fh 0095   1]                 _CST Support : 85
[060h 0096   2]                   C2 Latency : 0001
[062h 0098   2]                   C3 Latency : 0039
[064h 0100   2]               CPU Cache Size : 0000
[066h 0102   2]           Cache Flush Stride : 0000
[068h 0104   1]            Duty Cycle Offset : 01
[069h 0105   1]             Duty Cycle Width : 03
[06Ah 0106   1]          RTC Day Alarm Index : 0D
[06Bh 0107   1]        RTC Month Alarm Index : 00
[06Ch 0108   1]            RTC Century Index : 32
[06Dh 0109   2]   Boot Flags (decoded below) : 0012
               Legacy Devices Supported (V2) : 0
            8042 Present on ports 60/64 (V2) : 1
                        VGA Not Present (V4) : 0
                      MSI Not Supported (V4) : 0
                PCIe ASPM Not Supported (V4) : 1
                   CMOS RTC Not Present (V5) : 0
[06Fh 0111   1]                     Reserved : 00
[070h 0112   4]        Flags (decoded below) : 0000C2AD
      WBINVD instruction is operational (V1) : 1
              WBINVD flushes all caches (V1) : 0
                    All CPUs support C1 (V1) : 1
                  C2 works on MP system (V1) : 1
            Control Method Power Button (V1) : 0
            Control Method Sleep Button (V1) : 1
        RTC wake not in fixed reg space (V1) : 0
            RTC can wake system from S4 (V1) : 1
                        32-bit PM Timer (V1) : 0
                      Docking Supported (V1) : 1
               Reset Register Supported (V2) : 0
                            Sealed Case (V3) : 0
                    Headless - No Video (V3) : 0
        Use native instr after SLP_TYPx (V3) : 0
              PCIEXP_WAK Bits Supported (V4) : 1
                     Use Platform Timer (V4) : 1
               RTC_STS valid on S4 wake (V4) : 0
                Remote Power-on capable (V4) : 0
                 Use APIC Cluster Model (V4) : 0
     Use APIC Physical Destination Mode (V4) : 0
                       Hardware Reduced (V5) : 0
                      Low Power S0 Idle (V5) : 0

[074h 0116  12]               Reset Register : [Generic Address Structure]
[074h 0116   1]                     Space ID : 01 [SystemIO]
[075h 0117   1]                    Bit Width : 08
[076h 0118   1]                   Bit Offset : 00
[077h 0119   1]         Encoded Access Width : 00 [Undefined/Legacy]
[078h 0120   8]                      Address : 0000000000000CF9

[080h 0128   1]         Value to cause reset : 06
[081h 0129   2]    ARM Flags (decoded below) : 0000
                              PSCI Compliant : 0
                       Must use HVC for PSCI : 0

[083h 0131   1]          FADT Minor Revision : 00
[084h 0132   8]                 FACS Address : 00000000BBEE7000
[08Ch 0140   8]                 DSDT Address : 00000000BBFF1C9B
[094h 0148  12]             PM1A Event Block : [Generic Address Structure]
[094h 0148   1]                     Space ID : 01 [SystemIO]
[095h 0149   1]                    Bit Width : 20
[096h 0150   1]                   Bit Offset : 00
[097h 0151   1]         Encoded Access Width : 00 [Undefined/Legacy]
[098h 0152   8]                      Address : 0000000000001000

[0A0h 0160  12]             PM1B Event Block : [Generic Address Structure]
[0A0h 0160   1]                     Space ID : 00 [SystemMemory]
[0A1h 0161   1]                    Bit Width : 00
[0A2h 0162   1]                   Bit Offset : 00
[0A3h 0163   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0A4h 0164   8]                      Address : 0000000000000000

[0ACh 0172  12]           PM1A Control Block : [Generic Address Structure]
[0ACh 0172   1]                     Space ID : 01 [SystemIO]
[0ADh 0173   1]                    Bit Width : 20
[0AEh 0174   1]                   Bit Offset : 00
[0AFh 0175   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0B0h 0176   8]                      Address : 0000000000001004

[0B8h 0184  12]           PM1B Control Block : [Generic Address Structure]
[0B8h 0184   1]                     Space ID : 00 [SystemMemory]
[0B9h 0185   1]                    Bit Width : 00
[0BAh 0186   1]                   Bit Offset : 00
[0BBh 0187   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0BCh 0188   8]                      Address : 0000000000000000

[0C4h 0196  12]            PM2 Control Block : [Generic Address Structure]
[0C4h 0196   1]                     Space ID : 01 [SystemIO]
[0C5h 0197   1]                    Bit Width : 08
[0C6h 0198   1]                   Bit Offset : 00
[0C7h 0199   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0C8h 0200   8]                      Address : 0000000000001050

[0D0h 0208  12]               PM Timer Block : [Generic Address Structure]
[0D0h 0208   1]                     Space ID : 01 [SystemIO]
[0D1h 0209   1]                    Bit Width : 20
[0D2h 0210   1]                   Bit Offset : 00
[0D3h 0211   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0D4h 0212   8]                      Address : 0000000000001008

[0DCh 0220  12]                   GPE0 Block : [Generic Address Structure]
[0DCh 0220   1]                     Space ID : 01 [SystemIO]
[0DDh 0221   1]                    Bit Width : 80
[0DEh 0222   1]                   Bit Offset : 00
[0DFh 0223   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0E0h 0224   8]                      Address : 0000000000001020

[0E8h 0232  12]                   GPE1 Block : [Generic Address Structure]
[0E8h 0232   1]                     Space ID : 00 [SystemMemory]
[0E9h 0233   1]                    Bit Width : 00
[0EAh 0234   1]                   Bit Offset : 00
[0EBh 0235   1]         Encoded Access Width : 00 [Undefined/Legacy]
[0ECh 0236   8]                      Address : 0000000000000000


Raw Table Data: Length 244 (0xF4)

  0000: 46 41 43 50 F4 00 00 00 04 59 4C 45 4E 4F 56 4F  // FACP.....YLENOVO
  0010: 54 50 2D 36 4E 20 20 20 50 14 00 00 4C 4E 56 4F  // TP-6N   P...LNVO
  0020: 01 00 00 00 00 70 EE BB 9B 1C FF BB 00 02 09 00  // .....p..........
  0030: B2 00 00 00 F0 F1 00 80 00 10 00 00 00 00 00 00  // ................
  0040: 04 10 00 00 00 00 00 00 50 10 00 00 08 10 00 00  // ........P.......
  0050: 20 10 00 00 00 00 00 00 04 02 01 04 10 00 00 85  //  ...............
  0060: 01 00 39 00 00 00 00 00 01 03 0D 00 32 12 00 00  // ..9.........2...
  0070: AD C2 00 00 01 08 00 00 F9 0C 00 00 00 00 00 00  // ................
  0080: 06 00 00 00 00 70 EE BB 00 00 00 00 9B 1C FF BB  // .....p..........
  0090: 00 00 00 00 01 20 00 00 00 10 00 00 00 00 00 00  // ..... ..........
  00A0: 00 00 00 00 00 00 00 00 00 00 00 00 01 20 00 00  // ............. ..
  00B0: 04 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00  // ................
  00C0: 00 00 00 00 01 08 00 00 50 10 00 00 00 00 00 00  // ........P.......
  00D0: 01 20 00 00 08 10 00 00 00 00 00 00 01 80 00 00  // . ..............
  00E0: 20 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00  //  ...............
  00F0: 00 00 00 00                                      // ....

--------------020400020909000807060404
Content-Type: application/x-ns-proxy-autoconfig;
 name="facp.dat"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="facp.dat"

RkFDUPQAAAAEWUxFTk9WT1RQLTZOICAgUBQAAExOVk8BAAAAAHDuu5sc/7sAAgkAsgAAAPDx
AIAAEAAAAAAAAAQQAAAAAAAAUBAAAAgQAAAgEAAAAAAAAAQCAQQQAACFAQA5AAAAAAABAw0A
MhIAAK3CAAABCAAA+QwAAAAAAAAGAAAAAHDuuwAAAACbHP+7AAAAAAEgAAAAEAAAAAAAAAAA
AAAAAAAAAAAAAAEgAAAEEAAAAAAAAAAAAAAAAAAAAAAAAAEIAABQEAAAAAAAAAEgAAAIEAAA
AAAAAAGAAAAgEAAAAAAAAAAAAAAAAAAAAAAAAA==
--------------020400020909000807060404--
