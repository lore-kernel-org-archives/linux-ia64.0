From: Peter  Jarrett <Peterj@ami.com>
Date: Fri, 16 Jun 2000 01:49:41 +0000
Subject: [Linux-ia64] Linux/64, kernel 2.4.0-test1 non-functionality with multiple brid
Message-Id: <marc-linux-ia64-105590678205154@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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


