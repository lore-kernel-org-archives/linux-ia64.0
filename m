From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 21 Jan 2005 09:01:58 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <yq0d5vz17g9.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@engr.sgi.com> writes:

Jesse> On Thursday, January 20, 2005 1:03 am, Jes Sorensen wrote:
>> What about real memory and mapping it uncached? Do we need to play
>> the same trick before allowing it to be mapped uncached? and for IO
>> memory mapped uncached?

Jesse> Real memory that we map uncached or WC should be in it's own
Jesse> granule.  Since we don't have an allocator for that yet, it's
Jesse> generally an unsafe thing to do (there are exceptions though,
Jesse> like the mspec driver).  And yes, we should probably be
Jesse> consulting the EFI memory map before setting any attributes on
Jesse> a page (i.e. at memory init time and whenever we change the
Jesse> pgprot bits), but since almost all conventional memory can be
Jesse> mapped uncached or cached, and I think all I/O memory can be
Jesse> mapped uncached, I didn't worry about those cases (well, that
Jesse> and I doubt that many EFI memory maps are up to the task--it
Jesse> would be ashame to break a bunch of otherwise working machines
Jesse> by forcing them to move to a more complete EFI memory map).

I am working on an allocator for that very reason, however I plan to
make it more generic so one can stick more than just uncached memory
into it (in it's own seperate pool of course).

Cheers,
Jes
