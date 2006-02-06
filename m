From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Mon, 06 Feb 2006 20:40:32 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <516F50407E01324991DD6D07B0531AD5980C8C@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

One headsup before unpinning per-cpu...

In playing with paravirtualization for Xen/ia64, I saw
some evidence that replacing all uses of ar.kr's in Linux/ia64
with direct memory accesses to (pinned) per-cpu data may speed
up the kernel somewhat (~0.5%?).  (Reading/writing of kr's
on Mckinley is pretty slow... don't know about other processors.)

I talked to Peter Chubb about this at the October Gelato meeting
and we thought it might make a good undergraduate/master's
project/paper so I never reported it here.

However, if the TR used for pinning per-cpu gets used
for something else, this experiment will get much harder
to run so I thought I'd better post this headsup now.

Dan Magenheimer
HP Labs Fort Collins

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Chen, Kenneth W
> Sent: Friday, February 03, 2006 11:31 AM
> To: Luck, Tony; 'Dean Roe'; 'Jack Steiner'
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: ia64 printk_clock()
> 
> Luck, Tony wrote on Friday, February 03, 2006 10:04 AM
> > [1] http://tinyurl.com/ah642
> 
> Ha, should've check the archive :-)
> 
> Now that I read the whole thread, how about remove pining DTR 
> requirement for per-cpu data?  In alt_dtlb_miss, we can just
> detect whether ifa is per_cpu address and read ar.k3 to get the
> physical address, then insert a TC.  That will free up a tlb
> entry for application to use.
> 
> - Ken
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
