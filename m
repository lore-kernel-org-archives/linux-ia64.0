From: "Martin J. Bligh" <mbligh@aracnet.com>
Date: Tue, 14 Dec 2004 18:59:50 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <9250000.1103050790@flay>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de

> NUMA systems running current Linux kernels suffer from substantial
> inequities in the amount of memory allocated from each NUMA node
> during boot.  In particular, several large hashes are allocated
> using alloc_bootmem, and as such are allocated contiguously from
> a single node each.

Yup, makes a lot of sense to me to stripe these, for the caches that
are global (ie inodes, dentries, etc).  Only question I'd have is 
didn't Manfred or someone (Andi?) do this before? Or did that never
get accepted? I know we talked about it a while back.

M,


