From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 22 Sep 2003 21:04:46 +0000
Subject: Re: [HELP] latest discontig
Message-Id: <marc-linux-ia64-106426487929957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106305453930076@msgid-missing>
In-Reply-To: <marc-linux-ia64-106305453930076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 22, 2003 at 02:01:03PM -0700, David Mosberger wrote:
> >>>>> On Mon, 22 Sep 2003 13:31:15 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   >> I'm sorry, but until some of these criteria are met, there is no
>   >> way I'm going to apply this patch.  As for the breakage: as far
>   >> as I can see, the patch moves the bootmem initialization back to
>   >> the old place, which means that drivers/acpi/tables.c will fail
>   >> to allocate memory for the SDT again.
> 
>   Jesse> Len Brown already took the change to fix tables.c.
> 
> Perhaps I'm missing something, but I see this in Linus' tree:
> 
> Age      Author    Rev  Comments
>  7 weeks len.brown 1.15 match 2.4 -- more info in RSDT, nix some build warnings
> 11 weeks agrover   1.14 ACPI: Dynamically allocate SDT list (suggested by Andi Kleen)
> 
> No SDT fixes are far as I can see.

See
http://linux-acpi.bkbits.net:8080/linux-acpi-test-2.6.0/cset@1.1323.1.3?nav=index.html|ChangeSet@-4d.
It'll be part of Len's next push.  Sorry I should have kept that in the
patch so as not to confuse people.  I've been working hard to get all of
the non-ia64 specific code out into Linus' tree already, including some
bootmem allocator fixes and such, this one just took a little longer
because Andy stepped down as maintainer at around the same time I sent
my (trivial) patch out to fix this.

Btw, which piece(s) of the patch would you like first?  Is seperating
the contig and discontig functions into seperate files worthwhile?  I
can comment things a bit more too while I'm at it...

Thanks,
Jesse
