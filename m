From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Sat, 13 Mar 2004 00:22:00 +0000
Subject: RE: RE[PATCH]2.6.4-rc3 MSI Support for IA64
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502404058151@orsmsx404.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
In-Reply-To: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: long <tlnguyen@snoqualmie.dp.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, grep@kroah.com, jgarzik@pobox.com, "Nakajima, Jun" <jun.nakajima@intel.com>, "Luck, Tony" <tony.luck@intel.com>

On Fri, 12 Mar 2004, David Mosberger wrote:

>>>>> On Fri, 12 Mar 2004 18:26:39 -0500 (EST), Zwane Mwaikambo <zwane@linuxpower.ca> said:

>  Zwane> I wonder if we could consolidate these vector allocators as
>  Zwane> assign_irq_vector(AUTO_ASSIGN) has the same semantics as
>  Zwane> ia64_alloc_vector() and the one for i386 is also almost the
>  Zwane> same as its MSI ilk.

> Agreed.  I don't see any reason why ia64_alloc_vector() and
> assign_irq_vector() couldn't or shouldn't be one and the same thing
> (and assign_irq_vector() is a fine name).

Agree. Thanks!

> Tom, if you want to send me a patch that converts the existing uses of
> ia64_alloc_vector() to assign_irq_vector(), I'd be happy to apply
> (assuming it's clean etc., as usual).

Thanks! We'll do. I will work with Tony and Jun to consolidate i386/IA64 vector 
allocators to ensure it is clean.

Thanks,
Long
