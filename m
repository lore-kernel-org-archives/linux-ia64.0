From: "White, Charles" <Charles.White@COMPAQ.com>
Date: Tue, 24 Oct 2000 19:21:42 +0000
Subject: RE: [Linux-ia64] iosapic_vector struct in Linux IA64?
Message-Id: <marc-linux-ia64-105590678205618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205420@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205420@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Great!  When is the "next release"? 

From:	"Mallick, Asit K" <asit.k.mallick@intel.com
<mailto:asit.k.mallick@intel.com> >
To:	"'linux-ia64@linuxia64.org'" <linux-ia64@linuxia64.org
<mailto:linux-ia64@linuxia64.org> >
Subject:	RE: [Linux-ia64] iosapic_vector struct in Linux IA64?
Date:	Tue, 24 Oct 2000 10:48:42 -0700

I have been working on this issue and plan to get the changes incorporated
in the next release.
				Thanks,
				Asit


	> -----Original Message-----
	> From:	White, Charles [mailto:Charles.White@COMPAQ.com]
<mailto:[mailto:Charles.White@COMPAQ.com]> 
	> Sent:	Monday, October 23, 2000 9:11 AM
	> To:	'linux-ia64@linuxia64.org'
	> Subject:	[Linux-ia64] iosapic_vector struct in Linux IA64?
	> 
	> 
	> I am looking at an issue with Linux IA64, and the problem 
	> appears to be that
	> the ioapic_vector struct (iosapic.h) has only room for one
	> PCI/Bus/Dev/Func/Pin per PID entry... 
	> Being PCI devices can share interrupts, How do you handle 
	> that with only one
	> Entry?  Being even the PIN is part of the entry, you could 
	> not even tie INTA
	> & INTC together.   
	> Is anyone looking into this issue?  Has anyone been working on a
fix? 
	> 
	> 
	> _______________________________________________
	> Linux-IA64 mailing list
	> Linux-IA64@linuxia64.org <mailto:Linux-IA64@linuxia64.org> 
	> http://lists.linuxia64.org/lists/listinfo/linux-ia64
<http://lists.linuxia64.org/lists/listinfo/linux-ia64> 
	> 




--__--__--


