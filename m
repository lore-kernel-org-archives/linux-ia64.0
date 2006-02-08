From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 08 Feb 2006 21:38:25 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060208213825.GQ3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208035112.GM3524@stusta.de> <200602080552.k185q9g07813@unix-os.sc.intel.com> <20060208115946.GN3524@stusta.de> <yq0d5hym0lq.fsf@jaguar.mkp.net>
In-Reply-To: <yq0d5hym0lq.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 08, 2006 at 08:38:57AM -0500, Jes Sorensen wrote:
> >>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:
> 
> Adrian> On Tue, Feb 07, 2006 at 09:52:09PM -0800, Chen, Kenneth W
> Adrian> wrote:
> >> But for the bit that this thread started, which disables
> >> CONFIG_MCKINLEY for CONFIG_IA64_GENERIC, it is totally wrong and is
> >> the "over my dead body" type of thing.
> 
> Adrian> My initial patch that started this thread was to remove all
> Adrian> select's from CONFIG_IA64_GENERIC.
> 
> Adrian> Is this OK for you?
> 
> Adrian,
> 
> Not really, it helps a bit by selecting some things we know we need
> for all GENERIC builds. True we can't make it bullet proof, but whats
> there is better than removing it.

Like the bug of allowing the illegal configuration NUMA=y, FLATMEM=y?

> Jes

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

