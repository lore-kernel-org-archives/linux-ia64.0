From: Greg KH <greg@kroah.com>
Date: Mon, 23 Feb 2004 21:04:48 +0000
Subject: Re: [2.6 PATCH] Altix hotplug
Message-Id: <20040223210448.GA22598@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402231455.i1NEtEqJ041950@fsgi900.americas.sgi.com>
In-Reply-To: <200402231455.i1NEtEqJ041950@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 08:55:14AM -0600, Pat Gefre wrote:
> +#define SYSCTL_PCI_UNINITIALIZED	(SYSCTL_PCI_ERROR_BASE - 0)
> +    { SYSCTL_PCI_UNINITIALIZED, "module not initialized" },

What are you going to do with this large table of strings?  I see where
you copy them to somewhere, but don't see anything beyond that.

Are we missing a huge piece of the puzzle?

thanks,

greg k-h
