From: Jes Sorensen <jes@sgi.com>
Date: Wed, 08 Feb 2006 19:24:07 +0000
Subject: Re: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <43EA4557.6070107@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05A6DEE7@scsmsx401.amr.corp.intel.com> <1139426479.26420.189.camel@localhost>
In-Reply-To: <1139426479.26420.189.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Adrian Bunk <bunk@stusta.de>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Alex Williamson wrote:
> On Wed, 2006-02-08 at 10:35 -0800, Luck, Tony wrote:
> 
> 
>>The current set looks close ... perhaps PCI should be added as it isn't
>>likely to inconvenience anyone, but SMP is a lot further into murky territory
> 
> 
>    Seems like maybe PCI was removed so that it was possible to configure
> a generic kernel to boot on the simulator...  I could imagine not having
> PCI might have some degree of usefulness when using a ramdisk.  Isn't
> this what the defconfigs are for?

Hi Alex,

That could explain it, but the question is whether one would want to
boot a generic kernel when running on a simulator. After all then every
cycle does count ;)

Anyway I think we're down nit picking in details. My vote is for
preserving status quo.

Cheers,
Jes
