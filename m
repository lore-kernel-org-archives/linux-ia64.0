From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Oct 2003 21:36:23 +0000
Subject: RE: [PATCH 2.4.23-pre8]  Remove broken prefetching in free_one_pgd()
Message-Id: <marc-linux-ia64-106755041809902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106702916015259@msgid-missing>
In-Reply-To: <marc-linux-ia64-106702916015259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Friday 24 October 2003 4:21 pm, David Mosberger wrote:
> > >>>>> On Fri, 24 Oct 2003 15:16:59 -0700, "Luck, Tony" 
> <tony.luck@intel.com> said:
> >   >> Different arches behave differently, though.  In the 
> case of ia64,
> >   >> it'a always safe to prefetch (even with lfetch.fault).
> > 
> >   Tony> Not quite always ... this was how I found the efi 
> trim.bottom
> >   Tony> bug, since Linux had allocated a pgd at 
> 0xa00000-16k, and the
> >   Tony> lfetch that reached out beyond the end of the page to the
> >   Tony> uncacheable address 0xa00000 took an MCA.
> > 
> > But don't confuse cause and effect!  The MCA was caused by a bad TLB
> > entry.  The lfetch only triggered the latent bug (as might have a
> > instruction-prefetch).
> 
> I'm assuming that the EFI memory map trim fixes prevent the bad
> TLB entry, and hence, the prefetching patch is not required by ia64
> in 2.4.  Tony, let me know if otherwise.

If EFI trim is doing its job (and the current version now seems
to be handling all cases correctly), then you should no longer
be able to have a TLB entry erroneously marking an uncacheable
area of memory for cacheable access ... so you can keep the prefetch
for ia64 (David pointed out that dropping this prefetch has a
severe negative impact on lmbench fork+execve test).

-Tony
