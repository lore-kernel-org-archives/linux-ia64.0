From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 07 Oct 2004 17:22:48 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <200410071022.48569.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F022669A9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F022669A9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Patrick Gefre <pfg@sgi.com>, Grant Grundler <iod00d@hp.com>, Colin Ngam <cngam@sgi.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday, October 7, 2004 10:06 am, Luck, Tony wrote:
> >Yeah, sorry, I shouldn't have said cleanup, fixup is better.
> >Anyway, they
> >need to be separate since they'll be going into the tree via
> >Andrew not Tony.
>
> A couple of days back I said that I'm ok pushing these drivers.
> Although they don't have "arch/ia64" or "include/asm-ia64"
> prefixes, they are only used by ia64.  I'm even ok with the
> qla1280.c change as the final version is only touching code
> inside #ifdef CONFIG_IA64_{GENERIC|SN2) ... but I would like
> to see a sign-off from the de-facto maintainer Christoph for
> this file.

Ok great, that'll help keep things in good shape.

> However ... there's a thread on LKML wailing about huge changes
> going into "-rc" releases.  Since there still seems to be
> a lively discussion about the the right way to do the pci_root
> bits of this patch, I'm very inclined to save this till *after*
> Linus release 2.6.9-final.  If there's a _mostly_ clean patch
> presented to me before 2.6.10-rc1 shows up, I'll push that and
> allow for some follow-on tidy-up patches to clean up.

Sounds good, thanks Tony.

Jesse
