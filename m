From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Wed, 09 Aug 2000 21:41:31 +0000
Subject: RE: [Linux-ia64] Processor Rev.
Message-Id: <marc-linux-ia64-105590678205298@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,

I am using 2.4.0test4 with the trillian patch...

I noticed that 2.4.0test6pre9 is on www.kernel.org

Is the trillian patch merged on this kernel?


--ken

> -----Original Message-----
> From:	Stephane Eranian [SMTP:eranian@frankl.hpl.hp.com]
> Sent:	Wednesday, August 09, 2000 2:34 PM
> To:	linux-ia64@linuxia64.org
> Subject:	Re: [Linux-ia64] Processor Rev.
> 
> Hi,
> > 
> > [gerrit@elm3a86 palinfo]$ cat /proc/palinfo/version_info
> > PAL_vendor     : 0xff (min=0xff)
> > PAL_A revision : 0x9 (min=0x9)
> > PAL_A model    : 0x22 (min=0x22)
> > PAL_B mode     : 0x9 (min=0x0)
> > PAL_B revision : 0x22 (min=0x0)
> > 
> > There is other stuff of interest in /proc/palinfo.
> > 
> > Chris pointed out that the minor numbers of the version aren't included
> here.
> 
> In the latest kernel patch the output is slightly different. Here the
> minor
> number is .9. So 0x22 0x9 is read 2.2.9 for PAL version.
> 
> > 
> > Also, reading one of the files here caused a panic with the B1 CPU
> steppings.
> > 
> Yes, I am aware of this problem. I noticed yesterday while trying it out
> on our B1. I don't recall exactly which entry it is. I will be checking
> for that.
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


