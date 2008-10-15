From: Alexei Gerasimov <alex@netbynet.ru>
Date: Wed, 15 Oct 2008 15:01:24 +0000
Subject: qla1280 crash
Message-Id: <48F63750.70702@netbynet.ru>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!

I've been trying to boot various Linux distributions on an old Big-Sur 
prototype machine build on dual Itanium "Merced" processors (this 
machine was a prototype for HP i2000 workstation.) The outcome is always 
the same: the system goes down during the loading of qla1280 SCSI 
driver. Upon this, I get the following system event log entry:

Processor Device Error
 Map: 0x0000000001000000
 State: 0x20000000fff21320
 LID: 0x0000000003000000
 Bus:
  Valid: 0x0000000000000001
  Info: 0x0000000000000340
  Requester: 0x0000000000000000
  Responder: 0x0000000000000000
  Target: 0x0000000000000000
  IP: 0x0000000000000000
 CPU ID Info: 0x49656e69756e6547
 CPU ID Info: 0x000000006c65746e
 CPU ID Info: 0x0000000000000000
 CPU ID Info: 0x0000000007000604
 CPU ID Info: 0x0000000000000000
 CPU ID Info: 0x0000000000000000

What is this about exactly? Is this condition fixable?

Here's additional information about the box:

BIOS:  W460GXBS2.86E.0117C.P09.200108091154
SMBIOS:  2.3.1

PAL (A/B):  6623  6625
SAL (A/B):  101  101
Boot Block:  30

Please assist me in some way or direct me further, I'm going desperate 
on this machine. Thank you in advance,
Alexey G.

