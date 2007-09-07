From: "Natalie Protasevich" <protasnb@gmail.com>
Date: Fri, 07 Sep 2007 16:25:54 +0000
Subject: Re: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled
Message-Id: <32209efe0709070925t23451100t861dd4b92e6704e3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/7/07, Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> On Friday 07 September 2007 02:38:07 am Jes Sorensen wrote:
> > The reason why I suggested a machvec is to avoid cluttering up the
> > generic function with something like this. In addition I only see two
> > machvec's that may potentially get copied, the dig one and the hpzx1
> > one.
> >
> > If we start adding clutter to the generic functions we will end up with
> > a 2-dimensional mesh of things where some is handled machvec style and
> > then we have local variations within the machvecs. I suspect the Unisys
> > and HP machines will end up having special machvecs for these machines
> > anyway.
>
> I'm not aware of a current or planned HP machine where ptc.g will
> not work.
>
> Sometimes ptc.g doesn't work because of defects in early processor
> or chipset prototypes, but I consider that a bring-up issue that is
> not significant enough to warrant additional permanent code in the
> kernel.
>
> So I don't think we should have a special machvec for HP machines.
>

I think this clears the issue, because for Unisys it's more of
bring-up problem also, which may  or may not end up being a permanent
feature. Therefore it doesn't mean that the workaround is temporary,
and shouldn't be kept around for future use. It was needed some while
ago, and is needed again. But it looks like machvec is not an option
then (oh well :)
Thanks,
--Natalie
