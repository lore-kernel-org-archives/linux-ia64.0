From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 09 Dec 2005 00:10:20 +0000
Subject: Re: [discuss] Re: [PATCH 1/3] Zone reclaim V3: main patch
Message-Id: <Pine.LNX.4.62.0512081609400.31444@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208210850.GS11190@wotan.suse.de> <Pine.LNX.4.62.0512081320200.30786@schroedinger.engr.sgi.com>
 <20051208225102.GW11190@wotan.suse.de> <Pine.LNX.4.62.0512081514510.31246@schroedinger.engr.sgi.com>
 <20051208232827.GZ11190@wotan.suse.de> <Pine.LNX.4.62.0512081531150.31342@schroedinger.engr.sgi.com>
 <20051208234058.GA11190@wotan.suse.de>
In-Reply-To: <20051208234058.GA11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: steiner@sgi.com
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>, discuss@x86-64.org

On Fri, 9 Dec 2005, Andi Kleen wrote:

> Unless non local same box is 2 times as slow as the local I wouldn't
> consider that correct.  (I would expect the Altix to do better than that) 

Maybe Jack could give us a hint how these slit numbers relate to 
reality?

