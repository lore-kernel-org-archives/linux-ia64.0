From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 06 Dec 2007 21:34:34 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <20071206213434.GA24807@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 05, 2007 at 03:25:46PM -0800, Luck, Tony wrote:
> > Oh well, whatever.  Please treat this as a bug report.
> >
> > ie: someone please fix it.
> 
> Perhaps with?
> 
> -	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> +	-$(Q)READELF=$(READELF) python $(srctree)/arch/ia64/scripts/unwcheck.py $<

We do not have as much incompatibility among phython (or personal preference) than
we have for diver shells - so calling phython is fine.

That said I really do not like adding phython to the required tools even though
this is ia64 specific.
This script was previously written in perl wich is more widely used.
What was the exact reason switching to phython and can we do the same in perl?

	Sam
