From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 16:54:27 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <17065.50627.973606.726605@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Jun 2005 16:15:11 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Since the slab allocator uses addresses in region 7, we do
  Keith> not need any extra hard wired TLBs for the separate struct
  Keith> task.  The alt-DTLB handler will load the TLB on the fly, it
  Keith> does not need any stack data to do that.

Interruption handlers access the task structure, register-backing
store, and memory stack via the virtual address-space.  Since
interruption-collection is turned off in those handlers, the alt-DTLB
handler doesn't do you any good.

Being able to map these structures with a single translation-register
is the primary reason for keeping the task structure and the stacks
together on ia64.

	--david
