From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 08 Oct 2004 16:37:33 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <200410080937.33631.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com> <41645BDE.E9732310@sgi.com> <4166AF3D.9080808@sgi.com>
In-Reply-To: <4166AF3D.9080808@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: cngam@sgi.com
Cc: Matthew Wilcox <matthew@wil.cx>, Grant Grundler <iod00d@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Patrick Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday, October 8, 2004 8:16 am, Colin Ngam wrote:
> Now, if we can remove the static from pci_root_ops, I can use it in
> io_init.c, that would be cleanest and that was what we started with.
> This is what the patch would look like ontop of the 002_add* patch:

Yep, this looks good to me Colin.

> +extern struct pci_ops pci_root_ops;
> +
> +extern struct pci_ops pci_root_ops;
> +

...but of course you don't need to extern it twice :)

> We need a resolution so that Tony can proceed.  Silence is not going to
> help.

You've got my vote.

Jesse
