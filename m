From: Martin Hicks <mort@sgi.com>
Date: Tue, 15 Mar 2005 13:24:58 +0000
Subject: Re: bad pgd/pmd in latest BK on ia64
Message-Id: <20050315132458.GB19113@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F031272AF@scsmsx401.amr.corp.intel.com> <20050314143442.2ab086c9.davem@davemloft.net>
In-Reply-To: <20050314143442.2ab086c9.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


On Mon, Mar 14, 2005 at 02:34:42PM -0800, David S. Miller wrote:
> On Mon, 14 Mar 2005 14:06:09 -0800
> "Luck, Tony" <tony.luck@intel.com> wrote:
> 
> > Trying to boot a build of the latest BK on ia64 I see
> > a series of messages like this:
> > 
> > mm/memory.c:99: bad pgd e0000001feba4000.
> > mm/memory.c:99: bad pgd e0000001febac000.
> > mm/memory.c:99: bad pgd e0000001febc0d10.
> 
> Things are similarly busted on sparc64 for me as well.
> Things instantly reboot right after the kernel tries
> to open an initial console.

It's also busted on ia64 in 2.6.11-mm3 if that narrows thing down.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
