From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 19:55:58 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602081955.k18Jtug12275@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <43EA4557.6070107@sgi.com>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Jes Sorensen' <jes@sgi.com>, Alex Williamson <alex.williamson@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Adrian Bunk <bunk@stusta.de>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Jes Sorensen wrote on Wednesday, February 08, 2006 11:24 AM
> > Seems like maybe PCI was removed so that it was possible to configure
> > a generic kernel to boot on the simulator...  I could imagine not having
> > PCI might have some degree of usefulness when using a ramdisk.  Isn't
> > this what the defconfigs are for?
> > That could explain it, but the question is whether one would want to
> 
> boot a generic kernel when running on a simulator. After all then every
> cycle does count ;)


CONFIG_IA64_GENERIC select CONFIG_ACPI, and CONFIG_ACPI select CONFIG_PCI,
This whole thread is silly since the beginning and it is a moot point for
all of previous discussions.  What are we talking about exactly??

- Ken

