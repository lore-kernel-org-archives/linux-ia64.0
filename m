From: "David S. Miller" <davem@redhat.com>
Date: Sun, 15 Aug 2004 20:09:19 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <20040815130919.44769735.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


Is the read lock in the VMA semaphore enough to let you do
the pgd/pmd walking without the page_table_lock?
I think it is, but just checking.
