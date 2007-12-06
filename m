From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 06 Dec 2007 08:03:00 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <20071206000300.4138e247.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 6 Dec 2007 07:45:57 +0000 Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Dec 05, 2007 at 03:17:33PM -0800, Andrew Morton wrote:
> > > > -	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> > > > +	-$(Q)READELF=$(READELF) $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> > > 
> > > unwcheck.py is not a shell script.
> > > 
> > 
> > Oh well, whatever.  Please treat this as a bug report.
> > 
> > ie: someone please fix it.
> 
> Best would be to get rid of python.  Having another scripting language
> as built requirement, and that only on ia64 doesn't sound like a
> particularly good idea.

It's probably not a big deal - especially as ia64 kernels are presuably not
as likely to be built in wild and whacky enviroments like some other
architectures.

afacit the script is optional anyway - it "check and verifies unwind info".
If python isn't available, just skip it..  
