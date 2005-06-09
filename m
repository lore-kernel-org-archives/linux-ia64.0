From: Jack Steiner <steiner@sgi.com>
Date: Thu, 09 Jun 2005 19:47:13 +0000
Subject: Re: [patch 0/4] V2 ia64 SPARSEMEM
Message-Id: <20050609194713.GA13867@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050525151347.GB23448@localhost.localdomain>
In-Reply-To: <20050525151347.GB23448@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 25, 2005 at 05:44:06PM -0500, Jack Steiner wrote:
> On Wed, May 25, 2005 at 11:13:47AM -0400, Bob Picco wrote:
> ...
> > and HPSIM.  An early version of ia64 with SPARSEMEM was tested by Jesse. It
> > would be optimal to have another test pass on SGI NUMA hardware.
> 
> 
> I'm away from the office this week, but next week, I'll give the patch
> another spin on a big SGI system.
> 

Sorry to have taken so long but I had a number of problems getting the latest 
mm kernel to run reliably on our large systems. 

All of the page fault intensive tests that I ran on a 64p showed essentially
the same performance with & w/o SPARSEMEM enabled. 

I also ran AIM7 but was unsucessful drawing any conclusions from the results.
Something in the latest tree is causing large run-to-run variations - almost 2:1
at some load points. I'm trying  to determine the cause of these variations.

I have not had a chance to pull down the latest SPARSEMEM patches. I'll
do that once I understand the cause of the run-to-run variations.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


