From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 02 Sep 2004 15:31:36 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <200409020831.36425.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 1, 2004 11:10 pm, William Lee Irwin III wrote:
> On Wed, Sep 01, 2004 at 08:15:10PM -0700, William Lee Irwin III wrote:
> >> Okay, you're diving into node_alloc_mem_map() when you shouldn't be.
>
> On Thu, Sep 02, 2004 at 03:36:59PM +1000, Ian Wienand wrote:
> > OK, how about a patch like below for a start? node_alloc_mem_map()
> > calls alloc_bootmem_node() unconditionally, whereas we have already
> > setup a vmem map in arch/ia64/mm/contig.c:paging_init()
>
> You don't thave CONFIG_DISCONTIGMEM set? Why are you bothering with
> virtual mem_map if not?

The zx1 machines in particular have sparse memory layouts that need virtual 
memmap, but not CONFIG_DISCONTIGMEM.  Enabling CONFIG_DISCONTIGMEM should 
work around the bug though.

Jesse
