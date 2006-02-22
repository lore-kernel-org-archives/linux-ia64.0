From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 22 Feb 2006 00:39:35 +0000
Subject: Re: IA64 non-contiguous memory space bugs
Message-Id: <20060221.163935.32626284.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: david@gibson.dropbear.id.au
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: David Gibson <david@gibson.dropbear.id.au>
Date: Wed, 22 Feb 2006 11:13:59 +1100

> Quite some time ago, I found (by inspection) an ia64 specific bug
> related to its non-contiguous user address space.  I've never done
> anything about it, because I don't have an ia64 to test on - but
> somebody should fix it.  Recently I've spotted another possible bug,
> also by inspection - I don't know enough about ia64 to tell if it's a
> real problem or not.

Good catch David, I'll need to add similar checks on sparc64 as
we have a 64-bit virtual address space hole on several processors
there.
