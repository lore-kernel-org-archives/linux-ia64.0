From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 02 Jun 2004 14:15:17 +0000
Subject: Re: IA64 test report: USB mouse conflict with PS2 mouse 2.4.27-pre4
Message-Id: <20040602071517.53c5826c.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F840483B5BB@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F840483B5BB@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Jun 2004 20:33:25 +0800 Yu, Luming wrote:

| ACPI Test Report  for 2.4 ia64 kernel 
| ============| Hardware Configuration:
| -----------------------
| System Name: ACPI-LION
| System Type: 4 way 800M Itanium, Lion
| M/B revision: N/A
| Processor version: N/A
| Firmware Versions: N/A
| I/O configuration summary:
| 	QLogic QLA12160, Seagate ST39205LC boot drive
| 	IDE floppy and CDROM
| 	Serial console
| 	PS/2 keyboard and mouse
| 	USB mouse
| 	Ethernet Pro 100
| 
| Software Configuration:
| 	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.4 on
| 6/2(Shanghai time)
| 	2.bk pull from
| http://linux-acpi.bkbits.net/linux-acpi-test-2.4.27 on 6/2(Shanghai
| time)
| 
| ACPI Features Tested: (prioritized).
| --------------------
| 1. Boot 				tested ok
| 2. PS/2 keyboard			tested ok
| 3. ATI (run X window system)	tested ok
| 4. PS/2 mouse				tested ok
| 5. USB mouse				tested ok
| 6. NIC (eg. Ping or ftp)		tested ok
| 7. IDE (eg. r/w floppy or CDROM)	tested ok
| 8. SCI (eg. Press power button)	tested ok
| 9. Soft Power off 			tested ok
| 10. serial console			tested ok

So is there a problem here?  (like ps2/usb mice?)

I don't see it, but there was a post on lkml 2 days ago with a
patch to 2.6.x that may interest you.  See:
http://marc.theaimsgroup.com/?l=linux-kernel&m8602537100592&w=2


--
~Randy
