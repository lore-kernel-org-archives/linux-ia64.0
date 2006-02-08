From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 21:36:33 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602082136.k18LaXg20942@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060208212416.GA1593@parisc-linux.org>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Matthew Wilcox' <matthew@wil.cx>
Cc: 'Jes Sorensen' <jes@sgi.com>, Alex Williamson <alex.williamson@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Adrian Bunk <bunk@stusta.de>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Matthew Wilcox wrote on Wednesday, February 08, 2006 1:24 PM
> On Wed, Feb 08, 2006 at 11:55:58AM -0800, Chen, Kenneth W wrote:
> > CONFIG_IA64_GENERIC select CONFIG_ACPI, and CONFIG_ACPI select CONFIG_PCI,
> > This whole thread is silly since the beginning and it is a moot point for
> > all of previous discussions.  What are we talking about exactly??
> 
> I think the problem is that ia64 is abusing the 'select' feature.
> Select is a reverse dependency.  It should be used to turn things on
> which are required for this option to work.  Right now, the generic
> config uses it to turn on things which people think you probably want
> if you're building a generic kernel.
> 
> IMO, the select statements should be deleted.  They make it impossible to
> build a generic kernel without ACPI or NUMA.  While both are ubiquitous
> in ia64 implementations, they really aren't mandatory.

Things are mangled so badly that you can't even compile a generic kernel
after deselecting ACPI.

