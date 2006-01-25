From: "Bryan O'Sullivan" <bos@serpentine.com>
Date: Wed, 25 Jan 2006 22:46:43 +0000
Subject: Re: [Perfctr-devel] RE: [perfmon] Re: quick overview of the
Message-Id: <1138229203.15295.65.camel@serpentine.pathscale.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3C87FFF91369A242B9C9147F8BD0908A02C6955C@cacexc04.americas.cpqcorp.net>
	 <1138221212.15295.35.camel@serpentine.pathscale.com>
	 <20060125222844.GB10451@frankl.hpl.hp.com>
In-Reply-To: <20060125222844.GB10451@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfctr-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, perfmon@napali.hpl.hp.com, "Eranian, Stephane" <stephane.eranian@hp.com>, Andrew Morton <akpm@osdl.org>, "Truong, Dan" <dan.truong@hp.com>

On Wed, 2006-01-25 at 14:28 -0800, Stephane Eranian wrote:

> So it would help if you could
> name the extended features you referring to. 

I'm dubious about the hands-off buffer format in general.  Does this
mean that userspace needs to modprobe a specific set of modules in order
to do normal sampling?  If so, how do you work around the need for users
to be root in order to use these interfaces?

> And perfmon
> does allow it to continue working using almost all of its kernel code.
> This is leveraging the custom sampling buffer format support in perfmon.
> So you can say this is an extended feature that adds complexity.
> But OTOH, this is one elegant way of supporting an existing interface
> without breaking all the tools.

So are you saying that part of the existing oprofile code can be deleted
if perfmon is merged, and that userspace won't notice?

> We were able to proide this support
> with a few hundred lines of code without hacking the regular sampling
> format. Instead we simply created a dedicated PEBS format as a kernel module.

Does this mean I can't sample the PMCs on a P4 if I don't have the
special PEBS module loaded?  Do I need to be root to do that?

	<b

