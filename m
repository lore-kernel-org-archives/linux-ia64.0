From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Mar 2005 19:36:55 +0000
Subject: Re: [PATCH] remove redundant irq_affinity definition
Message-Id: <16949.59351.15900.222890@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503141128.01855.jbarnes@engr.sgi.com>
In-Reply-To: <200503141128.01855.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Mar 2005 11:28:01 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> What about for the mmu_context_t functions?

I looked briefly into this one and concluded that we shouldn't put the
"volatile" inside the mmu_context_t declaration.  Having said that,
we'll need to be very careful about this change to make sure we
compensate with the necessary barriers were we access context-ids
outside of spinlock-protected critical sections.

	--david
