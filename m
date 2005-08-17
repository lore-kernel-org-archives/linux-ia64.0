From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 Aug 2005 00:05:42 +0000
Subject: RE: [PATCH] Fix gcc 4 warnings on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0429483A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816155747.GN20749@wotan.suse.de>
In-Reply-To: <20050816155747.GN20749@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> You actually need the const attribute on __ia64_get_io_port_base

cscope didn't show any users of this function ... so I thought
perhaps the callers were in some macros that concatenated
strings with ## to make the name, but I couldn't see any.

So I tried the big hammer and just deleted the function
entirely to see what would complain, but nothing did (for
compile with defconfig and tiger_defconfig).

So unless something very, very, very subtle is happening
here, I'd say the fix would be to delete this function
altogether.  Rumours of better/worse code with/without
the "const" modifier look to be unfounded.

Hint: we also store ia64_iobase in ar.k0 ... so perhaps this
function has been obsolete for a while?

-Tony
