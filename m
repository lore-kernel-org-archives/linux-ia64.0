From: "CURRY,JOHN W (HP-Cupertino,ex1)" <john_w_curry@am.exch.hp.com>
Date: Wed, 05 May 2004 02:51:24 +0000
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <EFC4A8BDEDB4B846BC47F0ED773E812C089A56FD@xsun09.ptp.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Well, once it's working I think this will be okay for our team.
		Thanks,
			J. Curry

-----Original Message-----
From: Jesse Barnes [mailto:jbarnes@engr.sgi.com] 
Sent: Tuesday, May 04, 2004 9:34 AM
To: CURRY,JOHN W (HP-Cupertino,ex1)
Cc: 'Luck, Tony'; linux-ia64@vger.kernel.org
Subject: Re: [ia64 R&D] CONFIG_IA64_MCA


On Tuesday, May 4, 2004 9:06 am, CURRY,JOHN W (HP-Cupertino,ex1) wrote:
> Yes, I think that could work. Tell me more. I have already 
> communicated with Jesse, though.
It might look something like this (though now that I've looked at it, it
seems 
we could use an early option parser for ia64).  I've tried to add a 'nomca' 
boot option that you can pass to the kernel to avoid registering the MCA 
handlers with the firmware.  This kernel builds and boots for me w/o the 
'nomca' option, but on sn2 it hangs at boot if I pass 'nomca'. Jesse
