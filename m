From: Venkatesh Ramamurthy <Venkateshr@ami.com>
Date: Tue, 22 Feb 2000 23:02:59 +0000
Subject: [Linux-ia64] SoftSur Problem
Message-Id: <marc-linux-ia64-105590678204955@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I have compiled the kernel source code ( from kernel.org ) with the cross
compiler ( source code from cygnus). I booted the SoftSur System with the
new build of kernel. Since the softsur comes with QL1280 scsi card , i boot
through that device after copying the kernel into the proper directory. What
i am getting is a SCSI timeout in Qlogic driver when my kernel boots up. If
i try with the default kernel it works fine. 

Is there any special flag that i need to set when i do a 'make config'
during kernel compilation?

TIA
Venkatesh




