From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 25 Oct 2002 21:40:06 +0000
Subject: RE: [Linux-ia64] automount point hanging
Message-Id: <marc-linux-ia64-105590709805251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We have itanium I  loaded with redhat 7.1. Kernel version 
> 2.4.9-40smp. The
> server runs fine until users start to run CAD applications. The NFS
> automount point hang. /var/log/messages show :
> 
>  eepro100: wait_for_cmd_done timeout
> 
> Please advise what is the problem and whether or not there is 
> a patch for
> it.

There is a problem with the eepro100 driver.  You will also
see this if the card isn't getting interrupts for some reason.

You may have more luck with the e100 driver from intel.com

Kevin

