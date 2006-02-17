From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 17 Feb 2006 16:33:22 +0000
Subject: Re: [2.6 patch] show "SN Devices" menu only if CONFIG_SGI_SN
Message-Id: <20060217163322.GH4422@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217132245.GG4422@stusta.de> <yq08xsaxb0s.fsf@jaguar.mkp.net>
In-Reply-To: <yq08xsaxb0s.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 17, 2006 at 10:25:39AM -0500, Jes Sorensen wrote:
> >>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:
> 
> Adrian> On architectures like i386, the "Multimedia Capabilities Port
> Adrian> drivers" menu is visible, but it can't be visited since it
> Adrian> contains nothing usable for CONFIG_SGI_SN=n.
> 
> Thats only a third of the patch, if you want to do that, you should
> remove the redundant SGI_SN checks below.
> 
> Like this.

Looks good.

> Jes
>...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

