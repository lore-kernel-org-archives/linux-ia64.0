From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 20 Jan 2005 16:45:42 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501200845.42587.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 20, 2005 1:03 am, Jes Sorensen wrote:
> What about real memory and mapping it uncached? Do we need to play the
> same trick before allowing it to be mapped uncached? and for IO memory
> mapped uncached?

Real memory that we map uncached or WC should be in it's own granule.  Since 
we don't have an allocator for that yet, it's generally an unsafe thing to do 
(there are exceptions though, like the mspec driver).  And yes, we should 
probably be consulting the EFI memory map before setting any attributes on a 
page (i.e. at memory init time and whenever we change the pgprot bits), but 
since almost all conventional memory can be mapped uncached or cached, and I 
think all I/O memory can be mapped uncached, I didn't worry about those cases 
(well, that and I doubt that many EFI memory maps are up to the task--it 
would be ashame to break a bunch of otherwise working machines by forcing 
them to move to a more complete EFI memory map).

> Trying to map real memory uncached was what made me stumble upon the
> PREFETCH_VISIBILITY limitation in the PAL code.

Ah, I wondered about that :)

Jesse
