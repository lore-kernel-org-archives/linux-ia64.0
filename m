From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 16 Jun 2000 17:06:10 +0000
Subject: RE: [Linux-ia64] Linux/64, kernel 2.4.0-test1 non-functionality w
Message-Id: <marc-linux-ia64-105590678205157@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64 kernels and the LION systems do support multiple PCI buses; some older
kernels used to scan only 2 PCI buses and the newer kernels scans all the
buses. LION systems with FW version older than build 30/31 enables only 2
(bus 0 and bus 1) and later FWs enables all 4 buses.

Based on the problem you mentioned it appears that you are trying to read
the PCI configuration space for PCI interrupt line which will return you the
standard irq and not the IOSAPIC equivalent. The drivers need to use the irq
information available in the pdev structure. 

Hope this helps.

Asit


-----Original Message-----
From: Peter Jarrett [mailto:Peterj@ami.com]
Sent: Thursday, June 15, 2000 6:50 PM
To: 'linux-ia64@linuxia64.org'
Subject: [Linux-ia64] Linux/64, kernel 2.4.0-test1 non-functionality
with multiple brid ged PCI adapter --- who can help!


It have a controller that has 2 PCI-PCI bridge and 2 SCSI devices, however I
been having a hard time getting the IA-64 kernels to load my driver. Is
there a known limitation regarding multiple bus devices in these kernels and
the Intel Lion systems?

Pretty much what I see is....

*	pdev->irq returns with standard (PCI > Configuration Space) > irq
level INSTEAD of the IOSAPIC equivalent, which it Linux > should have >
done.... which in turns results in s timeout whenever the scsi mid-layer
firs the first TUR call.

Who can help? 


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



