From: David Miller <davem@davemloft.net>
Date: Tue, 25 Mar 2008 23:22:44 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080325.162244.61337214.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
	<20080324.144356.104645106.davem@davemloft.net>
	<Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 25 Mar 2008 10:48:19 -0700 (PDT)

> On Mon, 24 Mar 2008, David Miller wrote:
> 
> > There are ways to get large pages into the process address space for
> > compute bound tasks, without suffering the well known negative side
> > effects of using larger pages for everything.
> 
> These hacks have limitations. F.e. they do not deal with I/O and 
> require application changes.

Transparent automatic hugepages are definitely doable, I don't know
why you think this requires application changes.

People want these larger pages for HPC apps.
