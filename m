From: Kallol Biswas <kallol.biswas@s2io.com>
Date: Sat, 17 Jan 2004 01:53:07 +0000
Subject: Re: dma restriction on Itanium 2: more information on error
Message-Id: <1074304387.6384.16.camel@kbiswas-dt.s2iotech.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-01-16 at 17:48, Kallol Biswas wrote:
> We have been seeing a problem on itanium 2 running linux 2.4.21-4.EL 
> with our 10GB ethernet card.
> The error is PCI related. On PARISC systems the DMA address could not
> span page boundary due to hardware limitation, do we have the same
> limitation on Itanium 2 systems also? If the transmit or receive
> descriptors take more than a page then they should be aligned such a way
> that DMA does not happen over a page right?
> 
> 
> 
+Platform PCI Bus Error Info Section
+ PCI Bus Error Detail:  Error Status: 0x4a1800 Error Type: 0x2 Bus ID:
0x40 Bus Address: 0x0 Responder ID: 0xfed24000+Platform PCI Bus Error
Info Section
+ PCI Bus Error Detail:  Error Status: 0xa1800 Error Type: 0x2 Bus ID:
0x60 Bus
Address: 0x0 Responder ID: 0xfed26000+Platform PCI Bus Error Info
Section
+ PCI Bus Error Detail:  Error Status: 0x0 Error Type: 0x0 Bus ID: 0x60
Bus Address: 0x0+Platform PCI Bus Error Info Section
+ PCI Bus Error Detail:  Error Status: 0x0 Error Type: 0x0 Bus ID: 0x60
Bus Address: 0x0+END HARDWARE ERROR STATE AT CPE
+BEGIN HARDWARE ERROR STATE AT CPE
+Err Record ID: 22843435    SAL Rev:  0.02
+Time: 01/16/2004 17:30:37    Severity 2
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91600 GUID: <7>GUID fed28000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 04 00 00 04 00 00
00 00 00 00 08 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 10 00
00 00 00 00 ff 06 00 00 00 00 00 00 90 f8 ff 5f 01 00 12 00 00
 
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91100 GUID: <7>GUID fed26000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 80 86 44 42 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 03 00 00 04 00 00
00 00 00 00 40 02 00 00 00 00 00 00 84 86 44 42 00 00 00 80 00 00 00 00
00 00 00 00 00 00 10 00
00 00 00 00 f7 06 00 00 00 00 00 00 04 f8 ff 5f 01 00 12 00 00
 
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91100 GUID: <7>GUID fed26000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 00 8a e6 4e 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 03 00 00 04 00 00
00 00 00 00 40 02 00 00 00 00 00 00 00 8a e6 4e 00 00 00 80 00 00 00 00
00 00 00 00 c0 00 10 00
00 00 00 00 f7 06 00 00 00 00 00 00 04 f8 ff 5f 01 00 12 00 00
 
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0xe1600 GUID: <7>GUID fed26000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 03 00 00 04 00 00
00 00 00 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 10 00
00 00 00 00 f7 06 00 00 00 00 00 00 14 f8 ff 5f 01 00 12 00 00
 
+Platform PCI Bus Error Info Section
+ PCI Bus Error Detail:  Error Status: 0x4a1800 Error Type: 0x2 Bus ID:
0x40 Bus Address: 0x0 Responder ID: 0xfed24000+Platform PCI Bus Error
Info Section
+ PCI Bus Error Detail:  Error Status: 0xa1800 Error Type: 0x2 Bus ID:
0x60 Bus
Address: 0x0 Responder ID: 0xfed26000+Platform PCI Bus Error Info
Section
+ PCI Bus Error Detail:  Error Status: 0x0 Error Type: 0x0 Bus ID: 0x60
Bus Address: 0x0+Platform PCI Bus Error Info Section
+ PCI Bus Error Detail:  Error Status: 0x0 Error Type: 0x0 Bus ID: 0x60
Bus Address: 0x0+END HARDWARE ERROR STATE AT CPE
+BEGIN HARDWARE ERROR STATE AT CPE
+Err Record ID: 22843435    SAL Rev:  0.02
+Time: 01/16/2004 17:32:37    Severity 2
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91600 GUID: <7>GUID fed28000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 04 00 00 04 00 00
00 00 00 00 08 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 10 00
00 00 00 00 ff 06 00 00 00 00 00 00 90 f8 ff 5f 01 00 12 00 00
 
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91100 GUID: <7>GUID fed26000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 80 86 44 42 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 03 00 00 04 00 00
00 00 00 00 40 02 00 00 00 00 00 00 84 86 44 42 00 00 00 80 00 00 00 00
00 00 00 00 00 00 10 00
00 00 00 00 f7 06 00 00 00 00 00 00 04 f8 ff 5f 01 00 12 00 00
 
+Platform Specific Error Info Section
+ Platform Specific Error Detail:  Error Status: 0x91100 GUID: <7>GUID fed26000-0000-0000-0000-d0fe00000000
 OEM Specific Data: 00 8a e6 4e 00 00 00 00 00 00 00 00 00 00 00 00 2a
12 00 00
00 00 00 00 00 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 76 6c 27 13
de 37 e9 42 a5 2f 41 89 ba 10 dd ed 00 00 00 00 00 00 03 00 00 04 00 00
00 00 00 00 40 02 00 00 00 00 00 00 00 8a e6 4e 00 00 00 80 00 00 00 00
00 00 00 00 c0 00 10 00
00 00 00 00 f7 06 00 00 00 00 00 00 04 f8 ff 5f 01 00 12 00 00
 

lspci:
00:01.0 USB Controller: NEC Corporation USB (rev 41)
00:01.1 USB Controller: NEC Corporation USB (rev 41)
00:01.2 USB Controller: NEC Corporation USB 2.0 (rev 02)
00:02.0 IDE interface: CMD Technology Inc PCI0649 (rev 02)
00:03.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
(rev 0d)
00:1c.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
00:1d.0 Bridge: Hewlett-Packard Company zx1 I/O Controller (rev 23)
00:1e.0 Bridge: Hewlett-Packard Company zx1 System Bus Adapter (rev 23)
20:01.0 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
20:01.1 SCSI storage controller: LSI Logic / Symbios Logic 53c1030 PCI-X
Fusion-MPT Dual Ultra320 SCSI (rev 07)
20:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
40:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
60:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
80:01.0 Ethernet controller: Unknown device 17d5:5831 (rev 02)
80:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
c0:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)
e0:01.0 Communication controller: Hewlett-Packard Company Auxiliary Diva
Serial
Port (rev 01)
e0:01.1 Serial controller: Hewlett-Packard Company Diva Serial [GSP]
Multiport UART (rev 03)
e0:02.0 VGA compatible controller: ATI Technologies Inc Radeon RV100 QY
[Radeon
7000/VE]
e0:1e.0 Host bridge: Hewlett-Packard Company PCI-X/AGP Local Bus Adapter
(rev 32)


