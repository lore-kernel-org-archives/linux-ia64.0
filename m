From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 23 Apr 2004 07:09:14 +0000
Subject: RE: [PATCH][RFC] Vector sharing
Message-Id: <MDEEKOKJPMPMKGHIFAMAGEHNDNAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAOENCDMAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn,

> Yes, I think you're right.  Thanks for posting your patch.  I'll
> integrate that when I get some time to work on that again.
> (I apologize that it is taking me so long to get the patch
> straightened out.  I haven't had much time to work on it
> lately.)

I'm glad to contribute to your patch. I'll send comments or
patches again when I find something about your patch.


> I also agree that while my patch should reduce the usage of
> vectors, we will also need another mechanism to avoid running
> out.  I don't know whether the right answer is sharing,
> doing per-CPU vector allocation, some combination, or what.

Though the performance of per-CPU vector allocation is certainly
good, but I don't think it is good approach because the lack of
vector will happen in the following case:

	o if system has few CPUs
	o if CPUs are hot-removed by operator

The combination of sharing and per-CPU sounds good, though
I have not investigated it much yet. I think it is good for us to
implement vector sharing first, and implement per-CPU allocation
afterwards.

Thanks,
Kenji Kaneshige


> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> Sent: Thursday, April 22, 2004 1:45 PM
> To: Kenji Kaneshige
> Subject: Re: [PATCH][RFC] Vector sharing
> 
> 
> On Wednesday 21 April 2004 8:37 pm, you wrote:
> > I think both of your patch needs to get iosapic_lock in
> > iosapic_register_intr()
> > also. Please see following message:
> > 
> > http://www.gelato.unsw.edu.au/linux-ia64/0404/9352.html
> 
> Yes, I think you're right.  Thanks for posting your patch.  I'll
> integrate that when I get some time to work on that again.
> (I apologize that it is taking me so long to get the patch
> straightened out.  I haven't had much time to work on it
> lately.)
> 
> I also agree that while my patch should reduce the usage of
> vectors, we will also need another mechanism to avoid running
> out.  I don't know whether the right answer is sharing,
> doing per-CPU vector allocation, some combination, or what.
> 
> Bjorn
