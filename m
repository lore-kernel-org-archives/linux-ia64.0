From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 15 Mar 2005 18:40:35 +0000
Subject: Re: bad pgd/pmd in latest BK on ia64
Message-Id: <20050315104035.40549ea8.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F031272AF@scsmsx401.amr.corp.intel.com>
	<20050314143442.2ab086c9.davem@davemloft.net>
	<20050315132458.GB19113@localhost>
In-Reply-To: <20050315132458.GB19113@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Hicks <mort@sgi.com>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 15 Mar 2005 08:24:58 -0500
Martin Hicks <mort@sgi.com> wrote:

> It's also busted on ia64 in 2.6.11-mm3 if that narrows thing down.

Not necessary, we found the problem and the fix is in Linus's
tree.  The clear_page_range() had to be restored to using
pgd_index() looping at the top level.
