From: Gerald Pfeifer <gp@suse.de>
Date: Fri, 03 Feb 2006 23:40:04 +0000
Subject: Re: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <Pine.LNX.4.64.0602040031530.25309@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2 Feb 2006, Jes Sorensen wrote:
> We could do this in this particular case, but it doesn't solve the
> fundamental problem. What we really need is Intel showing that it will
> fix it's broken compilers once and for all if Intel wishes to continue
> compiling the kernel with it.

One thing I've always been wondering about: are there any relevant
users running ICC compiled kernels for real, or is this just an academic 
exercise?

Those distros I know about, and in at least one case I can assert this 
quite authoritatively ;-), never will go down this path, so I assume
there must be some adventurous users running home grown kernels?

Gerald
