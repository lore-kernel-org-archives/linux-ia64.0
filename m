From: "CURRY,JOHN W (HP-Cupertino,ex1)" <john_w_curry@am.exch.hp.com>
Date: Tue, 04 May 2004 16:06:41 +0000
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <EFC4A8BDEDB4B846BC47F0ED773E812C089A54CA@xsun09.ptp.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I think that could work. Tell me more. I have already communicated with
Jesse, though.
			Thanks,
				J. Curry

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
Sent: Tuesday, May 04, 2004 6:53 AM
To: John Curry; jbarnes@sgi.com
Cc: linux-ia64@vger.kernel.org
Subject: RE: [ia64 R&D] CONFIG_IA64_MCA


John> Hi, I have heard rumors that the CONFIG_IA64_MCA option may be 
John> phased out. If this is true, this email is an attempt to lobby 
John> AGAINST such a move.  I work with a team that explicitly disables 
John> the CONFIG_IA64_MCA so that the kernel will NOT handle MCAs. If 
John> kernel handling of MCAs is made automatic, then that would 
John> interfere with our use of the kernel. Hopefully, this rumor is 
John> false.

Would a boot option to skip registration linux handlers with SAL work for
you?  That would allow us to keep Jesse's cleanup that removes a bunch of
#ifdefs.

-Tony
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
