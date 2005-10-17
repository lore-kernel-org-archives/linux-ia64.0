From: Robin Holt <holt@sgi.com>
Date: Mon, 17 Oct 2005 11:39:04 +0000
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-Id: <20051017113904.GB30898@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com> <20051017113131.GA30898@lnx-holt.americas.sgi.com> <20051017113601.GA25434@infradead.org>
In-Reply-To: <20051017113601.GA25434@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Robin Holt <holt@sgi.com>, Greg KH <greg@kroah.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgarzik@pobox.com, wli@holomorphy.com, Dave Hansen <haveblue@us.ibm.com>, Jack Steiner <steiner@americas.sgi.com>

On Mon, Oct 17, 2005 at 12:36:01PM +0100, Christoph Hellwig wrote:
> On Mon, Oct 17, 2005 at 06:31:31AM -0500, Robin Holt wrote:
> > On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> > > On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > > > +EXPORT_SYMBOL(get_one_pte_map);
> > > 
> > > EXPORT_SYMBOL_GPL() ?
> > 
> > Not sure why it would fall that way.  Looking at the directory,
> > I get:
> 
> This is a very lowlevel export for things that poke deep into VM
> internals, so _GPL makes sense.  In fact not allowing modular builds
> of the mspec driver might make even more sense.

That would be acceptable as well.  I was just looking for a way to
minimize kernel sizes for ia64 machines that don't need these
devices and therefore would not load the module.  Just looking at
it from a distro perspective.  What is the concensus?

Thanks,
Robin
