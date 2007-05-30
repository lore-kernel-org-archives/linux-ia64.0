From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 30 May 2007 23:55:47 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <465E0F03.6000103@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929C15@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705301630360.3568@schroedinger.engr.sgi.com> <20070530163413.87ecfe18.randy.dunlap@oracle.com> <Pine.LNX.4.64.0705301652100.3731@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705301652100.3731@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

Christoph Lameter wrote:
> On Wed, 30 May 2007, Randy Dunlap wrote:
> 
>>> Right. I have no idea where to look. The function has no name? Or is the 
>>> segment .exit.text referenced by namne in .init.text?
>> Maybe 'objdump drivers/built-in.o and then grep that output (file)
>> for /exit.text/ ...

OK.  I would write the file to disk and view it with an editor.
Then at each occurrence of /exit.text/, see if it's inside an __init function...


> clameter@schroedinger:~/software/slub$ objdump -t drivers/built-in.o |grep "exit.text"
> 0000000000000000 l    d  .exit.text     0000000000000000 .exit.text
> 0000000000000000 l    d  *ABS*  0000000000000000 .rela.exit.text
> 0000000000000000 l    d  .IA_64.unwind_info.exit.text   0000000000000000 .IA_64.unwind_info.exit.text
> 0000000000000000 l    d  .IA_64.unwind.exit.text        0000000000000000 .IA_64.unwind.exit.text
> 0000000000000000 l    d  *ABS*  0000000000000000 .rela.IA_64.unwind.exit.text
> 0000000000000000 l     F .exit.text     0000000000000050 pcie_portdrv_exit
> 0000000000000060 l     F .exit.text     0000000000000040 aer_service_exit
> 00000000000000a0 l     F .exit.text     0000000000000040 pci_hotplug_exit
> 00000000000000e0 l     F .exit.text     00000000000000b0 pcied_cleanup
> 00000000000001a0 l     F .exit.text     0000000000000160 mspec_exit
> 0000000000000300 l     F .exit.text     0000000000000010 efi_rtc_exit
> 0000000000000320 l     F .exit.text     0000000000000010 agp_exit
> 0000000000000340 l     F .exit.text     00000000000000a0 sn_sal_module_exit
> 00000000000003e0 l     F .exit.text     0000000000000040 firmware_class_exit
> 0000000000000420 l     F .exit.text     0000000000000110 rd_cleanup
> 0000000000000540 l     F .exit.text     00000000000001d0 loop_exit
> 0000000000000720 l     F .exit.text     0000000000000040 tg3_cleanup
> 0000000000000760 l     F .exit.text     0000000000000040 idedisk_exit
> 00000000000007a0 l     F .exit.text     0000000000000040 ide_cdrom_exit
> 00000000000007e0 l     F .exit.text     00000000000000a0 exit_scsi
> 0000000000000880 l     F .exit.text     0000000000000080 spi_transport_exit
> 0000000000000900 l     F .exit.text     00000000000000a0 fc_transport_exit
> 00000000000009a0 l     F .exit.text     00000000000000e0 sas_transport_exit
> 0000000000000a80 l     F .exit.text     0000000000000040 sas_class_exit
> 0000000000000ac0 l     F .exit.text     0000000000000040 qla1280_exit
> 0000000000000b00 l     F .exit.text     0000000000000140 qla2x00_module_exit
> 0000000000000c40 l     F .exit.text     00000000000000a0 exit_sd
> 0000000000000ce0 l     F .exit.text     0000000000000060 ata_exit
> 0000000000000d40 l     F .exit.text     0000000000000040 vsc_sata_exit
> 0000000000000d80 l     F .exit.text     00000000000000d0 fusion_exit
> 0000000000000e60 l     F .exit.text     00000000000000e0 mptspi_exit
> 0000000000000f40 l     F .exit.text     00000000000000d0 mptfc_exit
> 0000000000001020 l     F .exit.text     00000000000000f0 mptsas_exit
> 0000000000001120 l     F .exit.text     0000000000000060 cdrom_exit
> 0000000000001180 l     F .exit.text     0000000000000080 input_exit
> 0000000000001200 l     F .exit.text     0000000000000070 mousedev_exit
> 0000000000001280 l     F .exit.text     0000000000000040 multipath_exit
> 00000000000012c0 l     F .exit.text     0000000000000240 md_exit
> 0000000000001500 l     F .exit.text     0000000000000090 dm_exit
> 00000000000015a0 l     F .exit.text     0000000000000170 efivars_exit
> 0000000000001720 l     F .exit.text     0000000000000010 hid_exit
> 


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
