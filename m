From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 09 Feb 2006 13:18:02 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060209131802.GE1593@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060208035112.GM3524@stusta.de> <200602080552.k185q9g07813@unix-os.sc.intel.com> <20060208115946.GN3524@stusta.de> <yq0d5hym0lq.fsf@jaguar.mkp.net> <20060208213825.GQ3524@stusta.de> <yq0zml0lmmg.fsf@jaguar.mkp.net>
In-Reply-To: <yq0zml0lmmg.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Adrian Bunk <bunk@stusta.de>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Keith Owens' <kaos@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 09, 2006 at 07:53:11AM -0500, Jes Sorensen wrote:
> There's other reasons why this is a moot exercise anyway, allyesconfig
> doesn't link on ia64 due to the size of the object exceeding the reach
> of the relative link relocs. Not much you can do about that.

That'd be a toolchain problem then ... need to insert stubs.

> - HP100 driver cannot be compiled on systems without ISA support in it's
>   current state.

I have it enabled on parisc without ISA or EISA.  More details, please.

>  config HP100
>  	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
> -	depends on NET_ETHERNET && (ISA || EISA || PCI)
> +	depends on NET_ETHERNET && ISA || EISA
>  	help

Also I think this is wrong.  Doesn't the precedence make this evaluate
as (NET_ETHERNET && ISA) || EISA ?
