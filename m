From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 15 Mar 2004 23:54:09 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040315235409.GM655@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de> <20040313184547.6e127b51.akpm@osdl.org> <40541A09.3050600@sgi.com> <20040314005737.7f57b8ad.akpm@osdl.org> <405550F6.1070203@sgi.com>
In-Reply-To: <405550F6.1070203@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Mar 15, 2004 at 12:45:10AM -0600, Ray Bryant wrote:
> I'd still rather see us do the "allocate on fault" approach with 
> prereservation to maintain the current ENOMEM return code from mmap()
> for hugepages. Let me work on that and get back to y'all with a patch
> and see where we can go from there.  I'll start by taking a look at
> all of the arch dependent hugetlbpage.c's and see how common they all
> are and move the common code up to mm/hugetlbpage.c.
> (or did WLI's note imply that this is impossible?)

It would be a mistake to put any pagetable handling functions in the
core. Things above that level, e.g. callers that don't examine the
pagetables directly in favor of calling lower-level API's, are fine.


-- wli
