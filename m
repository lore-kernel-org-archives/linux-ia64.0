From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 22 Sep 2004 23:21:28 +0000
Subject: Re: rename generic_defconfig to defconfig?
Message-Id: <200409221921.28832.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 22, 2004 7:05 pm, Luck, Tony wrote:
> >I could come up with a bigsur_defconfig next week (my machine
> >is due for a kernel upgrade).
>
> Attached is the config that I'm using on my Tiger at the
> moment (derived from generic by turning on DIG, turning off
> NUMA, dropping cpus from 512 to 4, and messing with a few
> device drivers).

I'm pretty sure CONFIG_VIRTUAL_MEM_MAP isn't needed either.  Also, which 
device drivers did you have to tweak?  Should those changes also go into 
generic_defconfig?

Thanks,
Jesse
