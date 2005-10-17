From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 17 Oct 2005 11:41:52 +0000
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-Id: <1129549312.32658.32.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>
	 <20051014192225.GD14418@lnx-holt.americas.sgi.com>
	 <20051014213038.GA7450@kroah.com>
	 <20051017113131.GA30898@lnx-holt.americas.sgi.com>
In-Reply-To: <20051017113131.GA30898@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Greg KH <greg@kroah.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Jack Steiner <steiner@americas.sgi.com>

On Mon, 2005-10-17 at 06:31 -0500, Robin Holt wrote:
> On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> > On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > > +EXPORT_SYMBOL(get_one_pte_map);
> > 
> > EXPORT_SYMBOL_GPL() ?
> 
> Not sure why it would fall that way.  Looking at the directory,
> I get:

Most of the VM stuff in those directories that you're referring to are
old, crusty exports, from the days before _GPL.  We've left them to be
polite, but if many of them were recreated today, they'd certainly be
_GPL.

We do not want random external modules poking at PTEs, nor should a
module need to know such kernel internals as the semantics of
PTE_HIGHMEM.  I think it needs _GPL.

BTW, your new patches look much nicer than the last set.  Thanks for
making the changes I suggested.

-- Dave

