From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 19 Sep 2002 22:48:32 +0000
Subject: RE: [Linux-ia64] Broadcom 5700 ethernet drivers
Message-Id: <marc-linux-ia64-105590701906043@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn,
Are you planning to do update of 2.4.19 kernel any time soon.  I want to
send you the hugetlb page patch for 2.4 kernels (David suggested that I
should directly send it to you).  So that you can include it in your next
patch. I'm currently having problems booting 2.4.19 (normal) kernel on my
Bigsur and Tiger machines.  

thanks,
rohit

> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn_helgaas@hp.com]
> Sent: Thursday, September 19, 2002 3:02 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Broadcom 5700 ethernet drivers
> 
> 
> The 2.4 ia64 tree currently has two drivers for Broadcom 5700
> devices: the "tg3" driver by Dave Miller and Jeff Garzik, and the
> "bcm" driver from Broadcom.
> 
> The tg3 driver is in the official kernels from Marcelo and Linus,
> is being actively maintained, and seems to be the current driver
> of choice.
> 
> The bcm driver is not in the upstream kernels, and doesn't seem
> to be headed there.
> 
> If you would like to keep the bcm driver in the 2.4 ia64 patches,
> please speak up and give me an idea of how long you'll need it,
> because I don't want to maintain the patch indefinitely.
> 
> Bjorn
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

