From: Thomas Renninger <trenn@suse.de>
Date: Mon, 13 Feb 2006 18:51:18 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <43F0D526.5010806@suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030904090900030306070805"
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E0452B0D7@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E0452B0D7@orsmsx403.amr.corp.intel.com>
To: "Moore, Robert" <robert.moore@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030904090900030306070805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Moore, Robert wrote:
> This only contains the output of stores to the ACPI "debug" object, not
> the full trace output. However, "_CRS 0" may help
> 
> 
Something is strange here.
With rc2-gitXY I got this:

-----------------------------------------------------------------------
slab error in cache_free_debugcheck(): cache `size-256': double free, or memory outside object was overwritten

Call Trace:
 [<a0000001000145c0>] show_stack+0x40/0xa0
                                sp=e00000011b7f7ae0 bsp=e00000011b7f1400
 [<a000000100014650>] dump_stack+0x30/0x60
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13e0
 [<a000000100134a50>] __slab_error+0x50/0x80
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13b0
 [<a000000100135ee0>] cache_free_debugcheck+0x220/0x600
                                sp=e00000011b7f7cb0 bsp=e00000011b7f1368
 [<a000000100139b70>] kfree+0xd0/0x480
                                sp=e00000011b7f7cb0 bsp=e00000011b7f1328
 [<a0000001002ea460>] acpi_os_free+0x20/0x40
                                sp=e00000011b7f7cc0 bsp=e00000011b7f1308
 [<a00000010031b980>] acpi_walk_resources+0x240/0x280
                                sp=e00000011b7f7cc0 bsp=e00000011b7f12c8
 [<a0000001003e4a10>] pci_acpi_scan_root+0x130/0x3e0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1278
 [<a000000100330380>] acpi_pci_root_add+0x480/0x620
                                sp=e00000011b7f7cf0 bsp=e00000011b7f1230
 [<a0000001003354c0>] acpi_bus_driver_init+0x80/0xe0
                                sp=e00000011b7f7d10 bsp=e00000011b7f1208
 [<a000000100337c80>] acpi_add_single_object+0x1480/0x1680
                                sp=e00000011b7f7d10 bsp=e00000011b7f11a0
 [<a000000100338110>] acpi_bus_scan+0x290/0x400
                                sp=e00000011b7f7d30 bsp=e00000011b7f1160
 [<a000000100645840>] acpi_scan_init+0x220/0x2c0
                                sp=e00000011b7f7d50 bsp=e00000011b7f1130
 [<a000000100009ee0>] init+0x540/0x880
                                sp=e00000011b7f7d60 bsp=e00000011b7f1108
 [<a0000001000128b0>] kernel_thread_helper+0xd0/0x100
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
 [<a0000001000094a0>] start_kernel_thread+0x20/0x40
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
e0000040f8de54c8: redzone 1: 0x170fc2a5, redzone 2: 0xf901001a00000028.
slab error in cache_free_debugcheck(): cache `size-256': double free, or memory outside object was overwritten

Call Trace:
 [<a0000001000145c0>] show_stack+0x40/0xa0
                                sp=e00000011b7f7ae0 bsp=e00000011b7f1400
 [<a000000100014650>] dump_stack+0x30/0x60
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13e0
 [<a000000100134a50>] __slab_error+0x50/0x80
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13b0
 [<a000000100135ee0>] cache_free_debugcheck+0x220/0x600
                                sp=e00000011b7f7cb0 bsp=e00000011b7f1368
 [<a000000100139b70>] kfree+0xd0/0x480
                                sp=e00000011b7f7cb0 bsp=e00000011b7f1328
 [<a0000001002ea460>] acpi_os_free+0x20/0x40
                                sp=e00000011b7f7cc0 bsp=e00000011b7f1308
 [<a00000010031b980>] acpi_walk_resources+0x240/0x280
                                sp=e00000011b7f7cc0 bsp=e00000011b7f12c8
 [<a0000001003e4af0>] pci_acpi_scan_root+0x210/0x3e0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1278
 [<a000000100330380>] acpi_pci_root_add+0x480/0x620
                                sp=e00000011b7f7cf0 bsp=e00000011b7f1230
 [<a0000001003354c0>] acpi_bus_driver_init+0x80/0xe0
                                sp=e00000011b7f7d10 bsp=e00000011b7f1208
 [<a000000100337c80>] acpi_add_single_object+0x1480/0x1680
                                sp=e00000011b7f7d10 bsp=e00000011b7f11a0
 [<a000000100338110>] acpi_bus_scan+0x290/0x400
                                sp=e00000011b7f7d30 bsp=e00000011b7f1160
 [<a000000100645840>] acpi_scan_init+0x220/0x2c0
                                sp=e00000011b7f7d50 bsp=e00000011b7f1130
 [<a000000100009ee0>] init+0x540/0x880
                                sp=e00000011b7f7d60 bsp=e00000011b7f1108
 [<a0000001000128b0>] kernel_thread_helper+0xd0/0x100
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
 [<a0000001000094a0>] start_kernel_thread+0x20/0x40
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
e0000040f89694c8: redzone 1: 0x170fc2a5, redzone 2: 0xf901001a00000028.
slab error in cache_free_debugcheck(): cache `size-256': double free, or memory outside object was overwritten

Call Trace:
 [<a0000001000145c0>] show_stack+0x40/0xa0
                                sp=e00000011b7f7a30 bsp=e00000011b7f16d8
 [<a000000100014650>] dump_stack+0x30/0x60
                                sp=e00000011b7f7c00 bsp=e00000011b7f16c0
 [<a000000100134a50>] __slab_error+0x50/0x80
                                sp=e00000011b7f7c00 bsp=e00000011b7f1690
 [<a000000100135ee0>] cache_free_debugcheck+0x220/0x600
                                sp=e00000011b7f7c00 bsp=e00000011b7f1648
 [<a000000100139b70>] kfree+0xd0/0x480
                                sp=e00000011b7f7c00 bsp=e00000011b7f1608
 [<a0000001002ea460>] acpi_os_free+0x20/0x40
                                sp=e00000011b7f7c10 bsp=e00000011b7f15e0
 [<a00000010031b980>] acpi_walk_resources+0x240/0x280
                                sp=e00000011b7f7c10 bsp=e00000011b7f15a0
 [<a00000010032c990>] find_pci_rootbridge+0x1d0/0x3a0
                                sp=e00000011b7f7c20 bsp=e00000011b7f1560
 [<a0000001003102d0>] acpi_ns_get_device_callback+0x270/0x2e0
                                sp=e00000011b7f7c60 bsp=e00000011b7f1508
 [<a000000100314880>] acpi_ns_walk_namespace+0x280/0x2e0
                                sp=e00000011b7f7c80 bsp=e00000011b7f1498
 [<a00000010030ff70>] acpi_get_devices+0xb0/0xe0
                                sp=e00000011b7f7c80 bsp=e00000011b7f1458
 [<a00000010032c790>] acpi_get_pci_rootbridge_handle+0x70/0xa0
                                sp=e00000011b7f7ca0 bsp=e00000011b7f1428
 [<a0000001002b8720>] pci_acpi_find_root_bridge+0x80/0xe0
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13f0
 [<a00000010032c0a0>] acpi_platform_notify+0x120/0x4c0
                                sp=e00000011b7f7cc0 bsp=e00000011b7f13b8
 [<a000000100391050>] device_add+0x230/0x300
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1378
 [<a000000100391150>] device_register+0x30/0x60
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1358
 [<a0000001002a7a90>] pci_create_bus+0x1b0/0x600
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1300
 [<a0000001002aa130>] pci_scan_bus_parented+0x30/0xa0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f12c8
 [<a0000001003e4b20>] pci_acpi_scan_root+0x240/0x3e0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1278
 [<a000000100330380>] acpi_pci_root_add+0x480/0x620
                                sp=e00000011b7f7cf0 bsp=e00000011b7f1230
 [<a0000001003354c0>] acpi_bus_driver_init+0x80/0xe0
                                sp=e00000011b7f7d10 bsp=e00000011b7f1208
 [<a000000100337c80>] acpi_add_single_object+0x1480/0x1680
                                sp=e00000011b7f7d10 bsp=e00000011b7f11a0
 [<a000000100338110>] acpi_bus_scan+0x290/0x400
                                sp=e00000011b7f7d30 bsp=e00000011b7f1160
 [<a000000100645840>] acpi_scan_init+0x220/0x2c0
                                sp=e00000011b7f7d50 bsp=e00000011b7f1130
 [<a000000100009ee0>] init+0x540/0x880
                                sp=e00000011b7f7d60 bsp=e00000011b7f1108
 [<a0000001000128b0>] kernel_thread_helper+0xd0/0x100
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
 [<a0000001000094a0>] start_kernel_thread+0x20/0x40
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
e00000011b7e76b0: redzone 1: 0x170fc2a5, redzone 2: 0xf901001a00000028.
slab error in cache_free_debugcheck(): cache `size-256': double free, or memory outside object was overwritten

Call Trace:
 [<a0000001000145c0>] show_stack+0x40/0xa0
                                sp=e00000011b7f7a30 bsp=e00000011b7f16d8
 [<a000000100014650>] dump_stack+0x30/0x60
                                sp=e00000011b7f7c00 bsp=e00000011b7f16c0
 [<a000000100134a50>] __slab_error+0x50/0x80
                                sp=e00000011b7f7c00 bsp=e00000011b7f1690
 [<a000000100135ee0>] cache_free_debugcheck+0x220/0x600
                                sp=e00000011b7f7c00 bsp=e00000011b7f1648
 [<a000000100139b70>] kfree+0xd0/0x480
                                sp=e00000011b7f7c00 bsp=e00000011b7f1608
 [<a0000001002ea460>] acpi_os_free+0x20/0x40
                                sp=e00000011b7f7c10 bsp=e00000011b7f15e0
 [<a00000010031b980>] acpi_walk_resources+0x240/0x280
                                sp=e00000011b7f7c10 bsp=e00000011b7f15a0
 [<a00000010032c990>] find_pci_rootbridge+0x1d0/0x3a0
                                sp=e00000011b7f7c20 bsp=e00000011b7f1560
 [<a0000001003102d0>] acpi_ns_get_device_callback+0x270/0x2e0
                                sp=e00000011b7f7c60 bsp=e00000011b7f1508
 [<a000000100314880>] acpi_ns_walk_namespace+0x280/0x2e0
                                sp=e00000011b7f7c80 bsp=e00000011b7f1498
 [<a00000010030ff70>] acpi_get_devices+0xb0/0xe0
                                sp=e00000011b7f7c80 bsp=e00000011b7f1458
 [<a00000010032c790>] acpi_get_pci_rootbridge_handle+0x70/0xa0
                                sp=e00000011b7f7ca0 bsp=e00000011b7f1428
 [<a0000001002b8720>] pci_acpi_find_root_bridge+0x80/0xe0
                                sp=e00000011b7f7cb0 bsp=e00000011b7f13f0
 [<a00000010032c0a0>] acpi_platform_notify+0x120/0x4c0
                                sp=e00000011b7f7cc0 bsp=e00000011b7f13b8
 [<a000000100391050>] device_add+0x230/0x300
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1378
 [<a000000100391150>] device_register+0x30/0x60
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1358
 [<a0000001002a7a90>] pci_create_bus+0x1b0/0x600
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1300
 [<a0000001002aa130>] pci_scan_bus_parented+0x30/0xa0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f12c8
 [<a0000001003e4b20>] pci_acpi_scan_root+0x240/0x3e0
                                sp=e00000011b7f7cd0 bsp=e00000011b7f1278
 [<a000000100330380>] acpi_pci_root_add+0x480/0x620
                                sp=e00000011b7f7cf0 bsp=e00000011b7f1230
 [<a0000001003354c0>] acpi_bus_driver_init+0x80/0xe0
                                sp=e00000011b7f7d10 bsp=e00000011b7f1208
 [<a000000100337c80>] acpi_add_single_object+0x1480/0x1680
                                sp=e00000011b7f7d10 bsp=e00000011b7f11a0
 [<a000000100338110>] acpi_bus_scan+0x290/0x400
                                sp=e00000011b7f7d30 bsp=e00000011b7f1160
 [<a000000100645840>] acpi_scan_init+0x220/0x2c0
                                sp=e00000011b7f7d50 bsp=e00000011b7f1130
 [<a000000100009ee0>] init+0x540/0x880
                                sp=e00000011b7f7d60 bsp=e00000011b7f1108
 [<a0000001000128b0>] kernel_thread_helper+0xd0/0x100
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
 [<a0000001000094a0>] start_kernel_thread+0x20/0x40
                                sp=e00000011b7f7e30 bsp=e00000011b7f10e0
e0000040fab29d88: redzone 1: 0x170fc2a5, redzone 2: 0xf901001a00000028.
Slab corruption: start=e0000040fab29ea8, len=256
Redzone: 0xad0e3701d2244a/0x5a2cf071.
Last user: [<a00000010028dbc0>](kobject_uevent+0x8a0/0x940)
000: 00 04 01 02 04 02 04 04 6b 6b 6b 6b 07 00 00 00
010: 0c 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b
Prev obj: start=e0000040fab29d90, len=256
Redzone: 0x5a2cf071/0x5a2cf071.
Last user: [<a0000001002ea460>](acpi_os_free+0x20/0x40)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
Next obj: start=e0000040fab29fc0, len=256
Redzone: 0x5a2cf071/0x5a2cf071.
Last user: [<a000000100415b20>](skb_release_data+0x1a0/0x1c0)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
-----------------------------------------------------------------------



I startet to pack the acpi functions in arch/ia64/pci/pci.c
(pci_acpi_scan_root()) into:
acpi_dbg_level=0x21FFFF;      /* Enable ACPI DEBUG */
...
acpi_dbg_level=0xF;           /* Disable ACPI_DEBUG */

However I now used a rc3 kernel and the pci_acpi_scan_root() function
with it's ACPI invokations succeeded. Has there any work been made?

The slab error now happens a bit later in (acpi_sba_ioc_add()).
So I set the acpi_debug trace there.

It is probably the:
ACPI_MEM_FREE(dev_info);
in arch/ia64/hp/common/sba_iommu.c:

Output and changes made are attached.
Any ideas?

Thanks,

     Thomas

--------------030904090900030306070805
Content-Type: application/x-bzip2;
 name="unaligned_access_debug.tar.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="unaligned_access_debug.tar.bz2"

QlpoOTFBWSZTWaAFM3oATOB/lf/+AIR7////f+//jv////4QAAQAgggACGAxD3y+baXvMrvU
1nG73vaenADzER177da9c7fOXsnL71Wnru62ILlx297OxNj111M2jdxuJjAU2Ncju9607efX
e+6+zr22vt8PsF99yiDzm7WK01vY49Zese7z3qehrbL1vbFe2XrI7AYqTY7s17sF7NAKAa8g
4eEkhAI0xNDImmE00aBGqeyTNU2jU2KbUNDygaZpNADT1ASRAmE0QmU0xJ6NJqekAGmgNPUA
ANMQDQ0AABpM0qTanohoaNADQ0AABoAAAAAAAABJpJQTRohoSeU9TYk9NTxEeJqB6gaNNqAA
AaAAHqARJBNIJNNMqfppppNKeGpqbTU/SnqeofpTaaTagemiGNT1ADQA0AqSEJkBNARpNoga
lPxNqaTUe1QGgb1TR+omnqAP1RkfqTQG0+s/V7tp/73jFTIE0gJBBjncc3QM84dMR0sC4gH3
lAg0h7OB8Cog4UCKiDgsQwFSWBYBYgkqBIpFKSUqSDms/cXCe+SFy0Cx9iQP/aQF0NCgFfmF
AM/CsPTRTKjKTc2ClYZNCWiVK2WC2xgtTdo9o7V948H1894/vMgWy2YjMIVhSUbArIAYT6pF
LSkKKVRFIGESbfci6MJmUOIlB+EPle+4f0BuZ1pg8ZCMH3BslTaSLf5pyYbUScSbydEtFVVR
iRRUQjFuIXEgnJjmYd2TABYSCesSCUJBPeE1zW2fhnRWx+LAnATULQT2xNZEh0kLJDW1goxS
ItAlogkURM6SPKuQmqIxP/1P5m2RBX9bAG57Es+uxzYF/BK/QvufNNVFJT1w+MIVfe++vnfp
4OdZ/OqjER1ZNWsjsNWqrcQ66yGn2RdjcTQmC1ZMAeYjO0ymRsa/JMbnUCHiIxHiJxJoDwhy
4qrSFKwTbOehzk0TrENwbyUndOAiIiIiIiIiIn9T2Dl3pqqCDQy4X5oPrampjhqIyOUAqUaF
DibXX/gZdGjroPV5TKZfRrNG99bA9UVPXtppm/crc1ScQnL0fdCxogAE9fuLgqhUVD1l1RFK
UpJFBSSkohPRSCI9mns9LenrW9vpla2lAEfWJ/p+qgJKi+0YOHjrhwsIB5xUhIdogZ2FfXaR
VfRP5bIvSJa8vcS9BFv6kkfavoiSjvKJCkUftEsFASWgCwGEGSQoIXgUMJzcXr2lrffe08H9
N+m42ialI8EQuiiSUlAwIK0qRVLBEIaPn+M+QsflMmhgdRKYkzxJsZ7967S3kvv1SwAEAkAn
tVSiu8qs0f6+Au8brEOG0C6Vp9242iC68RpdG+IiDWlO4AxQcIkEQxOSz/cA67XDPKI6DCbl
NjDypAXRK/k+k/Fy7bS4vZmTZQQNby+HzVoSECzn7E0/Y6n9A68H36GH+XZ/fEpDySKVFRGi
nybe1kmkgdIqdCQKh+7jdgkOwvnW+34PDsOj9kFpH64Fg3XPgcFmz/Dy9iFThFZze5w5fBbh
as2oed5nbWXmZM8qGvRnu9Ro8X7vrWmISAqkCCiqDycm+BYb8z4unufJpji7zgZTs9BLCiii
QYJxgiMI4SUieszRsmlLvmUYMUzR4ExqEuJy8nxjw38fZ0gdJJX0U2NgWnjnekBrEAA3qcjj
e/MgwiBpuqxKQogvAJTfzCHX3Z5ikI58cBHWIiImNh1ufjIZ99172IbZz9uwfNJf6kNrEO7f
pfyefTufz+7MChvL5A8Hi5ufXNqiBBo5DOI68c1cckjCVdQgxiDhLE+kvegCgQSSp5vCMoMG
VnsWDYMLrme+OF73oubFyiHpq5CGjaVqK+25Gsw0Ry5aba3NwdkMjkaY7O2NbazvMzbdp3cM
d0lo4d0MoRC47ORwhENIXE2EglxNXtU1shQhlCsVjSGEMIX1NU2cuBoc6lZzshhDWULDs6GF
ETZMlKRDVF4hQhshhjs7NnLlvM6mbFGNZuJod3GiJMoYRLIkUN1CWmja81vbbMad0N0LjoZa
29hyMTKZbtkLoYzWatcyTExbNkIhLxCwhuhZ03EKEIIZEJmZM4zcohl9gDygyAvgPA7LjCEp
EgJGQL4b13HLb94zMrdOZccy45lxzLjjnxz572QhrZtVXewxuX2J2DZkkmmGHiYJjg+ND4D0
u5MKJtuiIXqwJ8+uLdhsBqc0r2+1ovChn+O4IsIED5ICEs88mPJKR8chr1UR5ceYyHoKXCii
skym0hh1mEKtoy0z8hLyniwhoAt4ZyyFhlOvJ795uFO2+7weAb7jgZc7l1DV04GJ5UhtIchE
lO6TVFF28A5HCYRIkRE4NVVVVVBBgoooooou7OAenA5AYSUdPAQe0PpOPy4Y84ufGLMwg4iA
5LabYiz7ZQHATVuOlshm31RhCTEYPC+K4A1iYVQMbZ06meKjSTZqpdkzstewgT+VunzVI3Y5
6KzZ67Zcsmb5HgUZWS8Mr8Pg8dbV8dOHb0TkT4Jba6JIewD6USTkEgXT4hglwNOn0ZMdk1IC
AN1s0wfRHuLKgoo1aKREW1l0x6OPR/FmDjsM7jts8IRg/c45Fh5SePXBiqmezFlMgvduRAXq
x0ABOm+0QsZwQVdVQuaZpMHREvyxIMYQT/wEXCRjEaeaNE1iHZLBtlxBc2mWVLg951cezD6d
vVy2qvOkcG3HSQQ2JJHfIRgRduqk3Zu/bro8zAVy4jYlGeLfz9Hs+hIRPk15ICQgUn415j0j
kq7M7uSqOGDBw4cEEVAEXaM7ECYEPDsk2u/KEwjmSZJepniZBuqdXW7iGJzI4SROyA8b776N
tJDd3jMkk2HmnZOUhSD1oqqqsxK3wZ+IQxuHF48ebCw2E0OY6RDVQmk/CgR2jmnvc31be3t9
n6teHq0cqdKP1qpEPxUetaliIUPkkFQj4SSfer/8LvJu8p7/6fLDHOy8Z5iMFBywqCS8hKJu
2rxBi7AQSSPuWk5Pkjcwd2hgvPx+eWHniHGIROBcBjpVKKMJzYDLIlRF9jug5+j1uf6BUQf7
xQCdSiM8slCABEUgiSgBQYyQVEH/2hEV+SKAJc4HSeSOiOkxKr60VY+uxdGlpgZJiS0KqyCk
UliZLGGAVkL5JRirjBcbwTu0XuJFC7JlLoMoaAYNxKSGgNQpJEBIKQySGAZZIUKi5LWKWuJc
tei4lqSRYixA9yiBss9az7VafULLSb67+NvH6/vHCidgc/N8Xvr8G2B1+C9tAOt5tdE6manc
AzPSbCG5VVVVUZDcB3wksCyA7EpvMNhyGw0Qcjk2+o+bH0FSNokAeT3ryAUCQVMJFO+0Bn7M
Xdwpvvs0nz8VxvJz3eT8fMV4GWNhAgDfXbkLYCdBd16DWHjcdmXZS6urvy3Qj37MNEZqORN0
sEZtOU9CRp7P5bYbCxZaq/tY0uaVE7zpqx3CnPcmbXc6klbRLDrLJjRQqGIG0rVrbV3Gb/jE
Ok/hTRbDvxA5TpKTnBUinTcVJBAQ7ujUYoQs0kiJnauZoeD0oeRvCHjh1THKuh4VwzVa1DXi
YA2tsEZQN+y/LhW9ccSUnGvCZvCm3qdP8kzoW0p8XQQwh0musZ7nTrIE3kGApR0R2XLZulOX
Pl1KpyfpPRMoI10wS56056NHMmeCOjJy+ySEAQJmBcr6zVJzgIZkgCEiMFiFl3bY4j5FsxcW
I3XskQOuqxINjVl7oQ9SD+6CBXq55Ie53Ol9hAwZoHvuAkmOsQXSJYVWQRSFr47zhiSQ6GFE
ekSojDkNFAmMiw5BpGEdxDhASXZ2izG4OLBR15yFli6Kklha1iWEOJZQwKheahllEwCj9FgJ
rBpswEsWI2FL3EKYlngdrQhJcY9vitGdRGi+5P7Tc3NAwppZM7lXl10WFFLJYksUWWaNsInf
IUhtevN3TPSR5N5Y3Kb2a8YqDFIT1wxSr3gEP+4hXAh2xSwQThFCgiDBiqaKIeMp2gceQmhM
iXXZQ4sQeJBMkA7MG6rp5mcojiKm8SQTiQHYFbqVCQiiwcFyypYuoBMYuqVYGhLqIlcbvOt+
/hRvsO4mWu8ithAIM2gkUk0VI2sJZIwkDa1kCjarpqISQU7rTy3sP116W7VZV6pcuolwhxMt
xhbGml71K2KL1lIxGwGllWmiAszd4h8zbDxAJISjtc9JwAoqQLbpuTiMpksKyEk6pNCdsYB8
h+gjMtlgiqgd9hQ7VliMRkGIjBFioYacclMtGCDjKGQhZYUxKz8ZO8M5N1AHp9w6vYMsXW3P
to1FfObeITIbTVFeb7p2gWRO/tHxmqGY6eCvp5o9rhmnH0s7tpwl1Uy/nRekWlEj8jhyQQMb
kkto8IZB48Q+t0+lOrwLXbA1ISR+boUL0OCZd8Fhqk6iSB3K31iE2IWWoGYi5QqeG267eEe7
sxWTf7hvnBYZ6k71JajTYWWUmbfZJrnZIypnTnd00GGnjwmHtwp4QA1niUa3E8t8ZUOfjFVo
eEBxve1FX6mg0bPYZRM0oI0Jlpuxzukis51zADl5eCgELOstnWMC8GZknW3U/rgS6pmgkgeG
0O0fVbP4LzD6mSfOxYKkOpykWJEiRIREUalEyisuWrXjUG4lxLHjQyhdCw2aLp0F0L4yhdzg
xshZE2UL5zQ4wOE2QuWtSXzhhDCGL3XZVpbTWqpU7xZ2dqrMTf54X1xKUo977EEZh94stOCG
cDoB3GfmjLeA54xtcx8vPpmY2N8oj1m/jgc0CgVRaM6uSXIPfb1RwEHJB2KCA4yHQEoScjiB
e8KIOrataIGNQ5ThvqE2bNiYE29tz2tmxTqbszT3DKqqbRKQds3IUZK9J0TkhDyEQs2I98SE
PWAm7MzACblJw8qliwXrz+pm9HohJyOOtNEea9l69pWE6dkenyWxglxgXAsyial6Cp3TMrh4
oAXuePWOF+vjdru92cjTLok152yeoVnUjkes2KIRGEs7M6LLcoJjJFCUbz81tIzFabpSYBMp
51J3XZ8bH0Ipruo3m4z1Z511FY7hBWfbxf1ewW0yHZKc+9JKqF02DJinDnOAePpK7y5nPEwV
sOBjhCQTJSFCSbhQnhMF9SQhsVzcXsSiYxva3Isx3p5CAcu0u5qWWiPoeliZjP8bx7tjwASW
czKoWzWEU9Ljsb8ZKlJKZpUKVQpHZlG5rum1HU/AhxYR2CHSRQCAi+FABzwWhIk6cRHD5y8w
uaGhECXL0s2VsgwJ3cRrjdI1jAs+/WBCTN6HSSewfEDgrqS7AXiKEZhjTIjXhQeSuzGsls9m
C90KbsaCCWQtVsIUBfxtskJdSk1AtuyUgKMoDvZzXicYHybhzZLop49GSnPF+7vq5N+6qRXQ
OMKVUEvJGpQ1yttXppTgdMCcdEUN1rlJe2K7ewSxjiWSjsRRRLaIsS1EcqHE0ETFtHXcFb+I
6zqnF1zcRsnSyAXAYppmh1kc0dmJZFHmgigigd4IJKLvDQJ8x4Mm7kyQOcs0JAcl4zzaSoG6
xajHAGSFiBLRABsMhJNNGvYJJKpPtMS3qLWZqF6UGxAoYiezXM9BkKDhyHTBJoaLDABwA9WM
Cdps22HltWaXxR6yKnA2wTs27i+YgpKz8TypZBralLBOsNYa2rs35slmG7bPW97qVi8Nr2qG
0zS1qRnoPBn62e0jpNtuistsSRuQK48u8yc8teySQ8YQcAvQgiKRwCYiC00QWK6zzARdVKGj
4gIfaPFRSEI7KYMOy3ZStwjMwr0e+ItTk7u6e0WWzbUlu7RnGhlM9XsIjfiIzkkqyfGkdSuu
ApmDUaAtIMzwi4RMZpnQd3HZ2d3JSe9MP5TY8NCg1b8vS3DUjutkGkVCHEUUEQZg3QMNdSuz
PAUj0OJ4XbePB8Eic4I+fQRcYRglIaeDnBsjQU6dm0iZuD6nbYwI8SZR4D6DkkzK4nEbsGRZ
z3aYnfuWRakDL0as7eRRkiiqIBOwWBwH3odfK0DktKvKUkAkYs64qA6R2n8vgVYoWQquAjI+
BsPtRmHGd6KSCLoNMW10LoWvC1qHqYSyFkJM4DydhfHVWeN1eQ66Cy1d2mlmcw4WtUN4omnA
1RbbEbVG+mUqFIFUq8MC3hK04IzQLqb0fy78YQKnOSTWUEuXqtlSp7bhCAPikKtwZSQkg3lV
DMCE+V2HWvbPpDi5yD5kCkQzkfjPwPq9WO66YR9wao3IeQhqkPUQ+EKQ5+8BNhDOHZLabszC
2mHaIJNSdQiIqqqCCqqqqyDJRVLIrIpLmycpZKc6smqchSKNKl5GkmkqqEWkdFGdVOhYwcyx
riyMFI6Ivi9UkGdGSKFi7ThyL7Z6bhgDpXpGMkkkimDEG8FqJCFDJSGF1vHx9kIdfh5O3v8l
qY7/nXnKvqtesddZXbNm1fyzesCE/KU1ixOG/WMPNLm9fPekB4ceoLyYpgvzMCBu730FVVXj
tJoIH39pDA/PtIbghu3fp7N3FItwhyCVkomEKTjvpv4+PRx+/F+i14dVIqZNAfxooxa777+K
/yMdK0Z2r5ztg8Xw7szNJ3ZmbqX3/B2hWUYWcLf3OPh1OX18JX88+c8wJJhLVlSOXx1X+iEe
ID9oGBgH/EDQHWFgISwfV1O8NlWVhCT0vgrWXpTlX4kf9T6oX+iBEEn0k+T9AFKB4DBAA15/
SeDn/QYhQZ8CgL3qvRvhoCToMsIGz+LJGPP47e0aqR/QBxp1/+62Ic4fkRLo3ySi6f7UovI/
LBZUxJJvhw+Pt54TGMYw/i+zycR2+DekccccYQkkoSSsFYMrMrNLlhE7wJguI4YYWiopLbye
n5yeUnf27jbg7zzqSEOPHorxkiEtGaygWiog8+v2Y+rxGDrnb2XVDyweXonnip0blRZAkGIv
q9X/YRARuSSM4A6u8QMwgZXjWZrIQ13ugbWrczMraNGvu9Q5py85DiCQ9wKHmn54784aLyRx
junzzZMSHzoAyS683EwOJuKFKUKUoUpQpShSjg444OOODjkM9nGHZrKAQG8oVv2+EBvhebbb
vPdvfaHd9kN2fNouUquwk2kRbZtEP92fSR3paDOu1KT6F27uoCmqAWT1UakIJtSEEyRZpyN9
howxgg1io1pJEpE5FJDELRJ6aZKJSu2Gzx8HNse4xJg3rR4j6RDQ8FFoDgzuBeAAeTm5qwL5
tcvsI4rHGd4lbhUEIoYRqa34OLMjYhK1JGXIIgG9Dq7UhxbSFVO9E8zznUebmm6IZO4OnfrA
ODW4QOMUUE9lUoAFT6K/lJYET/gkD/J+XnDCKhXf+f+ua1/DvPFOsH21euIFhBJu4EdMoX0W
Tk7PC5KuzO7kxUqSoASoIzKA0hTZjHqNvrvcnIF5EoA/f5mQ/I3jIyMisUXZCc/NzM4iF5YG
1gKoHpix4VkFgLIo8i5zZirmZhCsBybGKLImEwyFJhhmoCwFgLAWSLASGMBpWRgVgKRgaYCi
wFk48xRTETJIRMVLiDUmKs1MJ1K1kglVBWRvhDGEMXc76NNxLppQ0m+4hub7m7vvuIbmhDRT
vhxlCuZVBNJDcujsbQJlDakN9tuDcatTfLmDnCFRCUZQ3gEi0poZVOsuYOIhV2+MFhozhDbK
GsGMIYwhjBiBIxhGbXGtU42doOTGEJRQSlOk2alIQB3UKzMLXV+JXVtKQ9YXoBLx+12o8XDl
0kZG6NPHuVwc6UhiQg7TAKMmJiZ6jfu7o9+ypIQ4ocTTbaMXveL3veL3veL/YSZ6cuZlM3LF
7vQJb8MhH8b9nqBD2Ce+BPoAHiKlh+sRoVPUWAPNYOz+bfD9QrQ4QuE+r8C7JP5P3LRpNVOe
uhRFFz/MuT29Dp0I4A42QyixQP1UDvgCgS5BUsA0IlG4Uilg/Ih07tuZJsyTycn7GrGRXcEy
BlDKnYQ0/bh4EPIXSjQqddF2EjkncklGa/eIp72axMpToqROYYLBRNCMjcRdG/EiwZjMXn5r
SDCRNU7SXjyeRDej40Q1SIybiBwIHbLEwQK4ervmXKdCNWeqZc8l0yJkkjWBN6ZktE3xA9fw
mTgpw5+qeT0XzmtmBrzh6gOXVklQLLQalkC2kaIqxGIqIqQVTcXRtF3Z9kz3IHwnOzHqHxSK
UjURFIWiwKRUSxqUPaayDythCXECMQguqhemWVxG3WCHg56c+/LgtVXSR5T2ViWlngNwXSRR
QT/A5/U2k9H1FI/PVCW+doaBCNoHWu0fbwoXWn6WGJZ8oAFYbuZzrhHOrVvBAE/xHPzcnF7H
wlByMSkVPRAciilj6QMBYEho627oFkZhO9JIxuiI/kK+TYR8QoklUs8M9E11Id2MCH6Q/jiR
UviRA5StGGHaIfgpIi38Cpq/ZqeXzNouPQazeXwbnmWLYE6kqeU8k6gB3TIJ3IURFwFSC0eG
s7SeaScEbBskkev819IiLQCfCiS4qUDAlIB1VEOx7043EPTLMtkDqQSTVm/XiFlSLaafHF73
N4vTVXwbWSs9IfWht1ocG1SexZq5WdiruCJ+CUiFOMh74viDkciE6r+UC++EV2s/r+9csbpU
GhX+a9k9VloUeo+1t3unG+X3PBkzKnnUSKoiA8nb3JtAvnytQQeOZqOLAFTks5QQlUsvaqkb
JTvJOg8zLRXLHLic3D1QQugkMYrQWvnOPujIppJs9QSiF0kGOh/d+ePbcrscuUeCSPe1mM9D
ij6go0UpKkyhadS9RZl8kguxLhORnHHJJB097UdI+awckzQ81r4EQ4+KGRUhR0SwQggyWPmF
6A5ho0YoPJ8ZxtkDsFSfx8VFNsfBbKZWdJKegEPuLFQMRPZBfuO4vfzG4GTuoku3evMWcoMm
E4hTwkQwkEN17Lkx3xAHdhV8Zt7rPcyc5708E4vXj2jYd+Z5kPQJeDIELT6Idrk6nXd5rIlp
1STIOyF8JI7treTw9gfdHwkUMK+leNNUd5QcuhKkJImVWK/acXgMPEbQ92yPwABgE8HRQQP7
Lkcb9kIlA/eMQT6ViEF0RwZKIqLxPzwBdyq1VsM/KTNx09PuEKjg99orwEm/aWO4TTbi+6ns
8iB0RoM0j2opKRQnrCWBr8DRA0RoLlkXQLH8CC6MtzOfWb1sDJZaRqiZIWkMBWP2Z0j7O5cI
I3AorTaumMbTnPF6CIajVviIzMwxQ19JKw8kbkHyVpE7EY5wMwIVjknwxeIW9ys8OiYezvYy
eQaePxc/s9wD+KApBQFj8FADwBBgZlltltO+mwXRCBUUhWSxUii3CMjIyMjIyPiN34vbeB8L
yMH7ayaVJDwJXMqwdRUutSqFXgjbrqwk6nzD2gnppUKEkN/MlonnFTpFXtLw9FzU93ymRHop
78ttloyI3qsuTOJFChGSmROz0fNLqjiiD9RGkgC4ue5fmWOIWSIUaG4v0iELOw5r5RLq224v
o3cVsqytUl7XPoV1ru3X5Br0auYcDSGO5aQniV9NaJQPt/isjlD8SxXJFo3/762l0VOUpLJI
2HRaWIl+c2NXsoQKn7a0SJj6Fg6RHe/jqcsP8PgRv6byZfFBvD6/SoFwDR0CJ3RhH4jpLScX
jlsodbNr5y6pS8zlDOm7Ace7JRGQh5+NItAPIlvwghFbiLDbnVl1vBUZJ3TpZBEusN8hO6Ch
hmdADUDtNIqbYBGQMIGc8ir8MGqTs0OiopMg4wqVUkqCilFUVQodIQ3Sv0nijQqoVNuuOHAV
2BkQsDVAkENYD1EnUlL66g1yNVqPOBm6Y+1Nph0dkvUAWFZ2PAMygOQQI52IH3qQudVLxbt/
dLvjJphGBuhCorcIEtN6ycZIWVBGbTLD/tYaBUUFbb6X82SO07JsiPATykiU51eXk4HDJKQ9
she0iCeY9oqhBiB75seFU+efzpXtnDpYoJepFvNX7KjyPNCpfhxI6QxuvEkaOFK2fQ0hdSKI
F4ZHwL4jcjcnzO1J6CnQqwiiUSVSBqP5oqnK15YorThoAxBIQYAPkAQCyPjiffNn8XbZom6T
qVrFU89auQvCRq0OO6TL6RdJFaobkkKdzS32iQKmggya/PIB7aK8JgbQfW5+HBwBAPDtcj3q
vO3UIrbHCyfIJQgvTvnJGWypD1I3ouv3UN1+N/Tz27NdjYsjya65Fk4calSilKn69j7rt8jq
9NEDBLqZ+MhJxA8v5/DZTRCQwqp1pAQ6YMM0hJGdZ6coXz5xafbKFwxUjNoDU56KkNEZwPVG
KiDIB3AgHyoeiFxNjzFHaKlJsToje8lJFUzk9o+BInyvjQTaTT9X2ff+muWh1pNziblwllMv
Hv9tlv+ly81di+XsMbw14g7dqt7oqQyY5NyBVrQCosFiKmAEAiNHfQopQ0Ng+++gT3Vx+z3U
iOjI1FXxNdz3gZEoExypLgSIo7DElwIqTnq+Tyl5xuQlDQEK6NqnVsBPLVyOqnbpHapffuRN
Co+NRIRyZO8kkZKSQUW9fGzVJFDhW05DbtRJN9VZEjMl971bdg01YUdJdbS/CXEDhxJUma/U
caoRuUJVAy/RU96NGSmUkaslnjVsdxeT58dUZW5HFEmfJkiq3o0TM7GlwToVGVFUUlFIn1yV
ZIe6yzYh8hGj8G6QnUgURhHUikUIeMEhboYbAH8S/ZdEOEIghiKrxHk6OqYBvuiYQRzQ3ELA
/niSJhYamLQ2ETUzFaRbhehQtBAkAEkASxFIHekiiIoMFIFkg2yxTs1TYTmDDdCwjUA6aEAs
oSMlQwasogi1JEcQxvUmScePwnhKn42JacUrQfZ3Q92YqifI+LiSd0K2BAB3cCqkVxQqByDF
Dt2nf3gp4MELD85yXRp/Qh6ewVORwyHS1QMD80OlpHcSSMsK+Ggx9yLgwIIDHSq+yrpTkFbM
UpOaRMZEP2oV0+m1dB0bkkeBF/x+HDPxfYi23styX0nkIH62bO8TwOM3ECqIH5CBjnzkieKe
cSkpJaynP91uefqtyirGBJzaLq0iFwgqM2MSE69SWI3CSHkTmYo9urKdIGDFuIItnJ77fa7g
d07RWeoE2ZhRH6AUiU+YaWC5HyuUrdOIgVHhIkVeMC3GSXH25nQ/xDN99CNbS5UBYkWt2JOi
FirTWl5BsiEdKQEVpxtby45BinapEd62bJKrgyXRTFa0XiigLJzHNEZEZESCMiMiMiPWQJRT
VgDZ3lKseXoYKpnwrl3gXA7/r97xSOgiNzpIgdU9m3aTp51xd6JOmXkDuRUy+6lnmi1kFIrd
ZZIlg5O7YN3ZWn3k3Qny4Q9hl3N4n6EOB776JHw4bJ4taXM5IPbLWJSTBv3Gzyk5EMOxly0x
rB4VJ9u+wnHlMyOUbmRdN0lGd0obpfoXkiYaFATEEEjA9W+bW+K5ltP1iZ2gaN0DXvbhoWpd
2LseYv+ob5nIlA4JR1HjHTXZwLYJTR0vJ7goikHFFIpFCKSKUUR0v2N7sdisrVkXrEy22Rsk
m5SzQKdRADBAS4RVHmQVvhoUi0IGlkkds8JH8LzvqzK4FMxJhEtH7/u6ve23o4vCRqmaBsgU
siyIG+1KzSJhkZT5qJlGvpHZggeW7m4V0qa/v0xc4dogfJ2ZtydCOxCg4arFyd7BgvJ1RJ+9
Em5eqYxPJO6YCYaoHJeVRW9KkrlzVU7t58O1sXI7yPJ87Q3Re8qls3X97mhHFRH4PHgw0k/u
U79Nu5Ez9O0hk7l/RhDtx4ofRqjK1pLJplbrEwUq8bb4uQ1RqtvKaNtU8c0GbUwSKiDe1XC2
qKsLItYWTWqvjLxHFNgtSogsSoRYigm4wMTJkkZoyDNImZAomVBMoFBglbjHM7OYXNMN7Qkk
YT/PWKJFrXBuQm8qilFEaAui0LEVJEWWuve5bbENDXIuiigocpVLYlClfopJKIpEnqNZIWav
lc1KRViVlwXEbDmmclbkSTczvV8qkMxz6WETskDDbuhIqg2oC7Le8ySwCL1IT9EhJIyvlFyd
slEkJXh02ZtYjfzC+XZekKi+8GFqACvxqvMZrkCDC+spSgAbGzroZMzDDMCqlckk/74y8jLC
rynEOMMgLUsCSC9u84hJF1tvVXqDviNCZedHupJanh52lk5t/wUMqCbUEqlVJEpSAqiSRzBu
iWkh7w0BShDfIYwSyiOqc5hV5a0PCVAmpKhConhINKkUkjD1ksNHY0M0uapliSTBK+FXmud7
pcgCzxeYUB8cUzOG4npT+AB+aCC5FYq/tKBE4ESyNulbHZg+WxnKogxReCiodUErt0Xue7BB
PC3EC1HlocodovNdxBx4JZ9yZDu+0A8nWCHQdnD9NfpFAnzUrJfEevybGKEif/F3JFOFCQoA
Uzeg
--------------030904090900030306070805--
