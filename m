From: Don Dugger <n0ano@valinux.com>
Date: Fri, 16 Mar 2001 21:25:33 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack-

I was working on this and discovered the same two problems you ran
into.  The alignment issue isn't really a problem, turns out that
where that directive is give the code is appropriately aligned
already so just remove the line should be OK.

The bitmap in `scsi_dma.c' is the real issue and needs to be re-written
in a more general fashion.  I don't really have time to work on this
right now so if you're interested go for it.  I'd be interested in
hearing about anything you find out.

On Fri, Mar 16, 2001 at 03:07:53PM -0600, Jack Steiner wrote:
> What is the status of support for 64K pagesizes in IA64. Is anyone
> actively working this??
> 
> I built a 2.4.2 kernel with 64K pages & immediately hit 2
> problems:
> 
> 	- gcc doesnt support 64K alignment (perhaps I am using
> 	  an old gcc??)
> 
> 	- drivers/scsi/scsi_dma.c has a bitmap 
> 	  that overflows with 64K pages.
> 
> 
> I dont mind working on these issues but first wanted to check if
> anyone else is working on them.
> 
> What other issues are people aware of that are lurking.....
> 
> 
> 
> -- 
> Thanks
> 
> Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

