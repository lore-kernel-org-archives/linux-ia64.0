From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 30 Sep 2005 16:03:08 +0000
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
Message-Id: <1128096188.6145.34.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
	 <1128092954.6145.12.camel@localhost>
In-Reply-To: <1128092954.6145.12.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>

On Fri, 2005-09-30 at 08:09 -0700, Dave Hansen wrote:
> On Fri, 2005-09-30 at 22:07 +0900, Yasunori Goto wrote:
> > I updated patches to remove pgdat link. They are for 2.6.14-rc2.
> > Please include this in your -mhp patch set.
> 
> Looks very nice.  I'll pull them in.

I spoke too soon :)

linux/mmzone.h uses the !NUMA NODE_DATA() before it is declared.  I'm
seeing if I can work around it now.

-- Dave

