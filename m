From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 09 Feb 2006 14:16:27 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060209141627.GD3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208035112.GM3524@stusta.de> <200602080552.k185q9g07813@unix-os.sc.intel.com> <20060208115946.GN3524@stusta.de> <yq0d5hym0lq.fsf@jaguar.mkp.net> <20060208213825.GQ3524@stusta.de> <yq0zml0lmmg.fsf@jaguar.mkp.net> <20060209131802.GE1593@parisc-linux.org> <yq0r76cll25.fsf@jaguar.mkp.net>
In-Reply-To: <yq0r76cll25.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 09, 2006 at 08:26:58AM -0500, Jes Sorensen wrote:
> >>>>> "Matthew" = Matthew Wilcox <matthew@wil.cx> writes:
>...
> >> - HP100 driver cannot be compiled on systems without ISA support in
> >> it's current state.
> 
> Matthew> I have it enabled on parisc without ISA or EISA.  More
> Matthew> details, please.
> 
> Generous use of isa_memcpy_toio, isa_readb etc. Those functions ought
> not be visible in a config where ISA is disabled.  Anybody who cares
> enough about this could easily fix the HP100 driver to deal with it,
> but it would require some reorganization of the code.
>...

A patch is already available:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/
  2.6.16-rc2/2.6.16-rc2-mm1/broken-out/
  remove-isa-legacy-functions-drivers-net-hp100c.patch

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

