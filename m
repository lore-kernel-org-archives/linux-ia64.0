From: Pat Erley <pat-lkml@erley.org>
Date: Mon, 12 Oct 2015 03:58:02 +0000
Subject: Re: [Linaro-acpi] [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <561B2FCA.1010504@erley.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030700060407040900090401"
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
 <560BA4C9.7090607@huawei.com> <560C0968.6020904@redhat.com>
 <2808057.teMg2oCLf6@vostro.rjw.lan> <5612AF64.4060900@redhat.com>
 <561B2442.9050600@erley.org> <561B2DAD.5070601@linaro.org>
In-Reply-To: <561B2DAD.5070601@linaro.org>
To: Hanjun Guo <hanjun.guo@linaro.org>, Al Stone <ahs3@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-acpi@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, linux-arm-kernel@lists.infradead.org

This is a multi-part message in MIME format.
--------------030700060407040900090401
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 10/11/2015 08:49 PM, Hanjun Guo wrote:
> On 10/12/2015 11:08 AM, Pat Erley wrote:
>> On 10/05/2015 10:12 AM, Al Stone wrote:
>>> On 10/05/2015 07:39 AM, Rafael J. Wysocki wrote:
>>>> On Wednesday, September 30, 2015 10:10:16 AM Al Stone wrote:
>>>>> On 09/30/2015 03:00 AM, Hanjun Guo wrote:
>>>>>> On 2015/9/30 7:45, Al Stone wrote:
>>>>>>> NB: this patch set is for use against the linux-pm bleeding edge
>>>>>>> branch.
>>>>>>>
>>>>>
>>>>> [snip...]
>>>>>
>>>>>>
>>>>>> For this patch set,
>>>>>>
>>>>>> Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
>>>>>>
>>>>>> Thanks
>>>>>> Hanjun
>>>>>
>>>>> Thanks, Hanjun!
>>>>
>>>> Series applied, thanks!
>>>>
>>>> Rafael
>>>>
>>>
>>> Thanks, Rafael!
>>>
>>
>> Just decided to test out linux-next (to see the new nouveau cleanups).
>> This change set prevents my Lenovo W510 from booting properly.
>>
>> Reverting: 7494b0 "ACPI: add in a bad_madt_entry() function to
>> eventually replace the macro"
>>
>> Gets the system booting again.  I'm attaching my dmesg from the failed
>> boot, who wants the acpidump?
>
> [    0.000000] ACPI: undefined version for either FADT 4.0 or MADT 1
> [    0.000000] ACPI: Error parsing LAPIC address override entry
> [    0.000000] ACPI: Invalid BIOS MADT, disabling ACPI
>
> Seems the MADT revision is not right, could you dump the ACPI MADT
> (APIC) table and send it out? I will take a look :)
>
> Thanks
> Hanjun

Here ya go, enjoy.  Feel free to CC me on any patches that might fix it.

--------------030700060407040900090401
Content-Type: application/x-ns-proxy-autoconfig;
 name="apic.dat"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="apic.dat"

QVBJQ7wAAAAB+kxFTk9WT1RQLTZOICAgUBQAAExOVk8BAAAAAADg/gEAAAAACAAAAQAAAAAI
AQEBAAAAAAgCAgEAAAAACAMDAQAAAAAIBAQBAAAAAAgFBQEAAAAACAYGAQAAAAAIBwcBAAAA
AQwBAAAAwP4AAAAAAgoAAAIAAAAAAAIKAAkJAAAADQAEBgAFAAEEBgEFAAEEBgIFAAEEBgMF
AAEEBgQFAAEEBgUFAAEEBgYFAAEEBgcFAAE=
--------------030700060407040900090401
Content-Type: text/x-dsl;
 name="apic.dsl"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="apic.dsl"

/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20150717-64
 * Copyright (c) 2000 - 2015 Intel Corporation
 * 
 * Disassembly of apic.dat, Sun Oct 11 20:55:40 2015
 *
 * ACPI Data Table [APIC]
 *
 * Format: [HexOffset DecimalOffset ByteLength]  FieldName : FieldValue
 */

[000h 0000   4]                    Signature : "APIC"    [Multiple APIC Description Table (MADT)]
[004h 0004   4]                 Table Length : 000000BC
[008h 0008   1]                     Revision : 01
[009h 0009   1]                     Checksum : FA
[00Ah 0010   6]                       Oem ID : "LENOVO"
[010h 0016   8]                 Oem Table ID : "TP-6N   "
[018h 0024   4]                 Oem Revision : 00001450
[01Ch 0028   4]              Asl Compiler ID : "LNVO"
[020h 0032   4]        Asl Compiler Revision : 00000001

[024h 0036   4]           Local Apic Address : FEE00000
[028h 0040   4]        Flags (decoded below) : 00000001
                         PC-AT Compatibility : 1

[02Ch 0044   1]                Subtable Type : 00 [Processor Local APIC]
[02Dh 0045   1]                       Length : 08
[02Eh 0046   1]                 Processor ID : 00
[02Fh 0047   1]                Local Apic ID : 00
[030h 0048   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[034h 0052   1]                Subtable Type : 00 [Processor Local APIC]
[035h 0053   1]                       Length : 08
[036h 0054   1]                 Processor ID : 01
[037h 0055   1]                Local Apic ID : 01
[038h 0056   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[03Ch 0060   1]                Subtable Type : 00 [Processor Local APIC]
[03Dh 0061   1]                       Length : 08
[03Eh 0062   1]                 Processor ID : 02
[03Fh 0063   1]                Local Apic ID : 02
[040h 0064   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[044h 0068   1]                Subtable Type : 00 [Processor Local APIC]
[045h 0069   1]                       Length : 08
[046h 0070   1]                 Processor ID : 03
[047h 0071   1]                Local Apic ID : 03
[048h 0072   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[04Ch 0076   1]                Subtable Type : 00 [Processor Local APIC]
[04Dh 0077   1]                       Length : 08
[04Eh 0078   1]                 Processor ID : 04
[04Fh 0079   1]                Local Apic ID : 04
[050h 0080   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[054h 0084   1]                Subtable Type : 00 [Processor Local APIC]
[055h 0085   1]                       Length : 08
[056h 0086   1]                 Processor ID : 05
[057h 0087   1]                Local Apic ID : 05
[058h 0088   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[05Ch 0092   1]                Subtable Type : 00 [Processor Local APIC]
[05Dh 0093   1]                       Length : 08
[05Eh 0094   1]                 Processor ID : 06
[05Fh 0095   1]                Local Apic ID : 06
[060h 0096   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[064h 0100   1]                Subtable Type : 00 [Processor Local APIC]
[065h 0101   1]                       Length : 08
[066h 0102   1]                 Processor ID : 07
[067h 0103   1]                Local Apic ID : 07
[068h 0104   4]        Flags (decoded below) : 00000001
                           Processor Enabled : 1

[06Ch 0108   1]                Subtable Type : 01 [I/O APIC]
[06Dh 0109   1]                       Length : 0C
[06Eh 0110   1]                  I/O Apic ID : 01
[06Fh 0111   1]                     Reserved : 00
[070h 0112   4]                      Address : FEC00000
[074h 0116   4]                    Interrupt : 00000000

[078h 0120   1]                Subtable Type : 02 [Interrupt Source Override]
[079h 0121   1]                       Length : 0A
[07Ah 0122   1]                          Bus : 00
[07Bh 0123   1]                       Source : 00
[07Ch 0124   4]                    Interrupt : 00000002
[080h 0128   2]        Flags (decoded below) : 0000
                                    Polarity : 0
                                Trigger Mode : 0

[082h 0130   1]                Subtable Type : 02 [Interrupt Source Override]
[083h 0131   1]                       Length : 0A
[084h 0132   1]                          Bus : 00
[085h 0133   1]                       Source : 09
[086h 0134   4]                    Interrupt : 00000009
[08Ah 0138   2]        Flags (decoded below) : 000D
                                    Polarity : 1
                                Trigger Mode : 3

[08Ch 0140   1]                Subtable Type : 04 [Local APIC NMI]
[08Dh 0141   1]                       Length : 06
[08Eh 0142   1]                 Processor ID : 00
[08Fh 0143   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[091h 0145   1]         Interrupt Input LINT : 01

[092h 0146   1]                Subtable Type : 04 [Local APIC NMI]
[093h 0147   1]                       Length : 06
[094h 0148   1]                 Processor ID : 01
[095h 0149   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[097h 0151   1]         Interrupt Input LINT : 01

[098h 0152   1]                Subtable Type : 04 [Local APIC NMI]
[099h 0153   1]                       Length : 06
[09Ah 0154   1]                 Processor ID : 02
[09Bh 0155   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[09Dh 0157   1]         Interrupt Input LINT : 01

[09Eh 0158   1]                Subtable Type : 04 [Local APIC NMI]
[09Fh 0159   1]                       Length : 06
[0A0h 0160   1]                 Processor ID : 03
[0A1h 0161   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[0A3h 0163   1]         Interrupt Input LINT : 01

[0A4h 0164   1]                Subtable Type : 04 [Local APIC NMI]
[0A5h 0165   1]                       Length : 06
[0A6h 0166   1]                 Processor ID : 04
[0A7h 0167   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[0A9h 0169   1]         Interrupt Input LINT : 01

[0AAh 0170   1]                Subtable Type : 04 [Local APIC NMI]
[0ABh 0171   1]                       Length : 06
[0ACh 0172   1]                 Processor ID : 05
[0ADh 0173   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[0AFh 0175   1]         Interrupt Input LINT : 01

[0B0h 0176   1]                Subtable Type : 04 [Local APIC NMI]
[0B1h 0177   1]                       Length : 06
[0B2h 0178   1]                 Processor ID : 06
[0B3h 0179   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[0B5h 0181   1]         Interrupt Input LINT : 01

[0B6h 0182   1]                Subtable Type : 04 [Local APIC NMI]
[0B7h 0183   1]                       Length : 06
[0B8h 0184   1]                 Processor ID : 07
[0B9h 0185   2]        Flags (decoded below) : 0005
                                    Polarity : 1
                                Trigger Mode : 1
[0BBh 0187   1]         Interrupt Input LINT : 01

Raw Table Data: Length 188 (0xBC)

  0000: 41 50 49 43 BC 00 00 00 01 FA 4C 45 4E 4F 56 4F  // APIC......LENOVO
  0010: 54 50 2D 36 4E 20 20 20 50 14 00 00 4C 4E 56 4F  // TP-6N   P...LNVO
  0020: 01 00 00 00 00 00 E0 FE 01 00 00 00 00 08 00 00  // ................
  0030: 01 00 00 00 00 08 01 01 01 00 00 00 00 08 02 02  // ................
  0040: 01 00 00 00 00 08 03 03 01 00 00 00 00 08 04 04  // ................
  0050: 01 00 00 00 00 08 05 05 01 00 00 00 00 08 06 06  // ................
  0060: 01 00 00 00 00 08 07 07 01 00 00 00 01 0C 01 00  // ................
  0070: 00 00 C0 FE 00 00 00 00 02 0A 00 00 02 00 00 00  // ................
  0080: 00 00 02 0A 00 09 09 00 00 00 0D 00 04 06 00 05  // ................
  0090: 00 01 04 06 01 05 00 01 04 06 02 05 00 01 04 06  // ................
  00A0: 03 05 00 01 04 06 04 05 00 01 04 06 05 05 00 01  // ................
  00B0: 04 06 06 05 00 01 04 06 07 05 00 01              // ............

--------------030700060407040900090401--
