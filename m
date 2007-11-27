From: Adrian Bunk <bunk@kernel.org>
Date: Tue, 27 Nov 2007 22:14:55 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <20071127221455.GH3406@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com> <20071127001430.083503280@sgi.com> <jehcj83uir.fsf@sykes.suse.de> <Pine.LNX.4.64.0711271016500.2310@schroedinger.engr.sgi.com> <jeabozs7ou.fsf@sykes.suse.de> <Pine.LNX.4.64.0711271331240.4803@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711271331240.4803@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andreas Schwab <schwab@suse.de>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Tue, Nov 27, 2007 at 01:38:02PM -0800, Christoph Lameter wrote:
>...
> Hmmm...
> 
> http://www.ohse.de/uwe/articles/gcc-attributes.html
> 
> says:
> 
> model (MODEL-NAME)
>     Found in versions: 2.8-3.4
>...

This site says at the top it used gcc versions up to 3.4, so it 
obviously can't find anything in gcc >= 4.0 ...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

