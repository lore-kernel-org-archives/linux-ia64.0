From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 01 Nov 2004 22:34:05 +0000
Subject: Re: rename generic_defconfig to defconfig?
Message-Id: <200411011434.05304.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409221713.12673.jbarnes@engr.sgi.com>
In-Reply-To: <200409221713.12673.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 22, 2004 4:23 pm, Jesse Barnes wrote:
> > Or maybe I'm the only one who's too lazy to mess with modules
> > for every build.
>
> No, I think you have a point there :)  I *really* don't like having to copy
> modules over.  If tg3 isn't builtin yet, it would be nice too.
>
> > I think generic_defconfig currently builds a McKinley kernel,
> > which may be the right thing, but you do have to remember
> > to switch back to CONFIG_ITANIUM for i2000.
>
> Right, but those boxes are mainly for the masochists among us, so I think a
> McKinley setting is the right choice.

Given the above, generic_defconfig seems to be in good shape to takeover as 
defconfig.  Tony?

Jesse
