From: Gerald Pfeifer <gp@suse.de>
Date: Thu, 03 Nov 2005 01:36:18 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <Pine.LNX.4.63.0511030159390.17121@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Nov 2005, Ian Wienand wrote:
> On Wed, Nov 02, 2005 at 11:16:11AM -0600, Robin Holt wrote:
> I must admit to be a bit perplexed however.  I would have thought that
> a customer who just spent (what I assume is a lot of) money on a
> machine to map huge areas of contiguous memory would really want to
> evaluate the probable benefits of larger pages, despite what Redhat
> ships.

I'll note that SUSE has been shipping a 64k-pagesize kernel for more
than a year now as part of SUSE LINUX Enterprise Server 9, and I have
not seen a single L3 support call for this kernel.

Which means that it's either completely bug free, or nobody uses it
in production. ;-)

> I'm probably just extremley naive as to what customers really
> want, however.

The reason customers generally prefer to go with default kernels,
as far as I can tell, is software certification.  If you're only
running your special applications, you may not care, but for such
huge memory configs a DBMS like Oracle or DB2 is often part of the
picture, for example.

Gerald
