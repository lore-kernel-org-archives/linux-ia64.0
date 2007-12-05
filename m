From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 05 Dec 2007 23:40:45 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <20071205154045.e207d656.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 5 Dec 2007 15:25:46 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> > Oh well, whatever.  Please treat this as a bug report.
> >
> > ie: someone please fix it.
> 
> Perhaps with?
> 
> -	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> +	-$(Q)READELF=$(READELF) python $(srctree)/arch/ia64/scripts/unwcheck.py $<

Spsoe so.  We get fancy with CONFIG_SHELL, but for flex/bison/gperf it
appears that kbuild just expects them to be present in $PATH.

Sam?
