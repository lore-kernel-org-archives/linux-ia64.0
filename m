From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Sep 2004 06:09:30 +0000
Subject: RE: Problem with no mem_map arg to init functions change?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01F524B7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Thanks to all the explanations I think I'm starting to understand all
>these options; I'll try to document things a little more fully in our
>WiKi soon (http://www.gelato.unsw.edu.au/IA64wiki if you've never seen
>it).
>
>I applied the following trivial patch and things seem to work now.
>This way, pfn_to_page(0) returns 0xa0007fff... (the virtual mem map)
>which I belive to be correct.

Ian (and Bill),

Thanks for all the work you both put into this ... patch accepted
and in my bk trees for Andrew and Linus to pick up.

-Tony
