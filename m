From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 19 Oct 2000 17:38:00 +0000
Subject: RE: [Linux-ia64] iosapic.c NULL pointer deref
Message-Id: <marc-linux-ia64-105590678205598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205597@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205597@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

This code was put in specifically for AMI MegaRaid controller and bridge
cards. Mike from Intel did the patch. Anyway, I am working on the IOSAPIC
code to fix a problem and would like to fix this problem also. Please let me
know if you have any suggestion.

Thanks,
Asit


> -----Original Message-----
> From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
> Sent: Wednesday, October 18, 2000 3:12 PM
> To: linux-ia64@linuxia64.org
> Cc: peterj@ami.com
> Subject: [Linux-ia64] iosapic.c NULL pointer deref
> 
> 
> In the 2.4.0-test8 and -test9 IA-64 patch, the file 
> arch/ia64/dig/iosapic.c,
> function pci_for_each_dev(), the bridge pointer can be NULL, but gets
> dereferenced anyhow, causing a nice tombstone.  I see this with an AMI
> MegaRAID 471 card that happens to have two bridges on it.  
> Putting in tests
> against NULL, that routine doesn't blow up any longer, but 
> interrupts are
> not properly assigned to that card then, and eventually all SCSI
> reads/writes time out.
> 
> I'm happy to work with whomever is responsible for this code 
> to have it
> properly assign interrupts to these cards.
> 
> Thanks,
> Matt
>  
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


