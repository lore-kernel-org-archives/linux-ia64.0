From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 10 Mar 2005 22:19:53 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <20050310221953.GB31638@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 10, 2005 at 06:02:33PM +0100, Andreas Schwab wrote:
> Greg Howard <ghoward@sgi.com> writes:
> 
> > On Thu, 10 Mar 2005, Andreas Schwab wrote:
> >
> >>
> >> Or even better: replace scdrv_buffer_to_int by be32_to_cpup.
> >
> > Sounds like a good idea.  Will be32_to_cpup work if the
> > argument isn't word-aligned?
> 
> Probably not, ie. it will result in an unaligned access.

but we have get_unaligned() for that..
