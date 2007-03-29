From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 29 Mar 2007 17:18:02 +0000
Subject: Re: [patch 0/5] ia64 memory attribute fixes
Message-Id: <20070329101802.b3c52124.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211616.17257.bjorn.helgaas@hp.com>
In-Reply-To: <200703211616.17257.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 29 Mar 2007 08:54:04 -0600 Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> On Wednesday 21 March 2007 16:16, Bjorn Helgaas wrote:
> > This series fixes a few memory mapping issues on ia64.  Outline:
> > 
> >   1  rename ioremap variables to match i386 (no functional change)
> >   2  use page table mappings in ioremap to avoid unsupported attributes
> >   3  allow WB mmap of /sys/.../legacy_mem
> >   4  fail mmaps that span areas with incompatible attributes
> >   5  update documentation & add tests
> > 
> > These are independent except that 2 depends on 1.
> 
> Andrew, I should have copied you on this series so you could put
> it in -mm (assuming you think it looks reasonable).
> 
> Tony plans to apply the series after 2.6.21 pops, but it'd be
> nice to get a little runtime before then.
> 
> Should I forward the series to you, or do you have copies?
> 

My linux-ia64 feed seems to have broken, so a resend would be appreciated,
thanks.

