From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 30 Aug 2000 22:27:07 +0000
Subject: RE: [Linux-ia64] iosapic_vector struct in Linux IA64?
Message-Id: <marc-linux-ia64-105590678205421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205420@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205420@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have started looking at this problem. Please let me know if you have done
anything on this. 

Thanks,
Asit
 

> -----Original Message-----
> From: White, Charles [mailto:Charles.White@COMPAQ.com]
> Sent: Wednesday, August 30, 2000 2:37 PM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] iosapic_vector struct in Linux IA64?
> 
> 
> I am looking at an issue with Linux IA64, and the problem 
> appears to be that
> the ioapic_vector struct (iosapic.h) has only room for one
> PCI/Bus/Dev/Func/Pin per PID entry... 
> 
> Being PCI devices can share interrupts, How do you handle 
> that with only one
> Entry?  Being even the PIN is part of the entry, you could 
> not even Tie INTA
> & INTC together.   
> 
> Is anyone looking into this issue? 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


