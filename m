From: Cliff Larsen <clarsen@egenera.com>
Date: Thu, 11 Nov 2004 17:18:47 +0000
Subject: RE: [PATCH] make INIT# handler call panic
Message-Id: <1100193526.16960.245.camel@clarsen>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-11-10 at 20:14, Luck, Tony wrote:
> You could change the call to ia64_sal_set_vectors in ia64_mca_init
> to point all cpus to just one routine (pass pointer to the same
> routine for monarch/slave) ... and then have the OS init code
> handle the serialization.  That would work on both correct and
> buggy SAL implementations.
> 
> -Tony

Certainly true. Do you have any sense of how widespread the problem
is? Being relatively new to Itanium and having just a SR870BH2 
to work with, I'm wondering whether such a workaround would be
generally useful.

-- 
Cliff Larsen <clarsen@egenera.com>

