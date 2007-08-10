From: Dean Nelson <dcn@sgi.com>
Date: Fri, 10 Aug 2007 01:06:59 +0000
Subject: [RFC 0/3] SGI Altix cross partition memory (XPMEM)
Message-Id: <20070810010659.GA25427@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com


    Terminology

The term 'partition', adopted by the SGI hardware designers and which
perculated up into the software, is used in reference to a single SSI
when multiple SSIs are running on a single Altix. An Altix running
multiple SSIs is said to be 'partitioned', whereas one that is running
only a single SSI is said to be 'unpartitioned'.

The term '[a]cross partition' refers to a functionality that spans between
two SSIs on a multi-SSI Altix. ('XP' is its abbreviation.)

    Introduction

This feature provides cross partition access to user memory (XPMEM) when
running multiple partitions on a single SGI Altix. XPMEM, like XPNET,
utilizes XPC to communicate between the partitions.

XPMEM allows a user process to identify portion(s) of its address space
that other user processes can attach (i.e. map) into their own address
spaces. These processes can be running on the same or a different
partition from the one whose memory they are attaching.

    Known Issues

XPMEM is not currently using the kthread API (which is also true for XPC)
because it was in the process of being changed to require a kthread_stop()
be done for every kthread_create() and the kthread_stop() couldn't be called
for a thread that had already exited. In talking with Eric Biederman, there
was some thought of creating a kthread_orphan() which would eliminate the
need for a call to kthread_stop() being required.

