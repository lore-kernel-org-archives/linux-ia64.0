From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Mon, 27 Feb 2006 20:28:08 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <88056F38E9E48644A0F562A38C64FB60075F68B4@scsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 

>-----Original Message-----
>From: Luck, Tony 
>Sent: Monday, February 27, 2006 11:19 AM
>To: Chen, Kenneth W; Zhang, Yanmin
>Cc: linux-ia64@vger.kernel.org; Pallipadi, Venkatesh; Siddha, 
>Suresh B; Zhang, Yanmin
>Subject: RE: Export cpu cache info by sysfs
>
>
>Are there any applications that look at 
>/sys/devices/system/cpu/cpu*/cache*?
>

I don't know of any application that use this interface today. Though we
want applications to be using it, I don't think this interface is
publicised enough for aplications to be using it yet. The i386 version
went in pretty recently (2.6.14 or so)... 

Thanks,
Venki
