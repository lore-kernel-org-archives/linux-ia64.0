From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 Nov 2005 03:55:07 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051103035506.GA8611@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 03, 2005 at 02:36:18AM +0100, Gerald Pfeifer wrote:
> On Thu, 3 Nov 2005, Ian Wienand wrote:
> > On Wed, Nov 02, 2005 at 11:16:11AM -0600, Robin Holt wrote:
> > I must admit to be a bit perplexed however.  I would have thought that
> > a customer who just spent (what I assume is a lot of) money on a
> > machine to map huge areas of contiguous memory would really want to
> > evaluate the probable benefits of larger pages, despite what Redhat
> > ships.
> 
> I'll note that SUSE has been shipping a 64k-pagesize kernel for more
> than a year now as part of SUSE LINUX Enterprise Server 9, and I have
> not seen a single L3 support call for this kernel.
> 
> Which means that it's either completely bug free, or nobody uses it
> in production. ;-)

You are probably correct that very few sites use it. Part of the reason is 
that the 64k-pagesize kernel is built with NR_CPUS8 - not 512. I suspect
that many of the big-memory sites have more than 128p. That makes the 64K page
kernel unusable for those sites.

In addition, the 64k-pagesize kernel does not have KDB configured. That
makes support more difficult. Many sites use the "arch-kdb" commands
to take quick dumps after system failures.

(and of course it really is bug free :-)


> 
> > I'm probably just extremley naive as to what customers really
> > want, however.
> 
> The reason customers generally prefer to go with default kernels,
> as far as I can tell, is software certification.  If you're only
> running your special applications, you may not care, but for such
> huge memory configs a DBMS like Oracle or DB2 is often part of the
> picture, for example.

True...

> 
> Gerald
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

.Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


