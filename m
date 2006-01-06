From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 06 Jan 2006 17:26:15 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060106172615.GE19769@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7AFB@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F055A7AFB@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, Jan 06, 2006 at 09:19:28AM -0800, Luck, Tony wrote:
> Would it be impossibly hard to make the >64 cpus case (when the code
> switches from a single word to an array) be dependent on a boot-time
> variable?  If we could, then the defconfig could just say 128, and
> users of monster machines would just boot with "maxcpus@96" to increase
> the size of the bitmask arrays.

Why can't we keep the default below 64?  Surely the 0.1% of the market
which needs more than 64 cpus can recompile their kernel ...
