From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 07 Sep 2007 16:11:17 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <200709071011.17942.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 07 September 2007 02:38:07 am Jes Sorensen wrote:
> The reason why I suggested a machvec is to avoid cluttering up the
> generic function with something like this. In addition I only see two
> machvec's that may potentially get copied, the dig one and the hpzx1
> one.
> 
> If we start adding clutter to the generic functions we will end up with
> a 2-dimensional mesh of things where some is handled machvec style and
> then we have local variations within the machvecs. I suspect the Unisys
> and HP machines will end up having special machvecs for these machines
> anyway.

I'm not aware of a current or planned HP machine where ptc.g will
not work.

Sometimes ptc.g doesn't work because of defects in early processor
or chipset prototypes, but I consider that a bring-up issue that is
not significant enough to warrant additional permanent code in the
kernel.

So I don't think we should have a special machvec for HP machines.

Bjorn
