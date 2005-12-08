From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 08 Dec 2005 23:35:05 +0000
Subject: Re: [discuss] Re: [PATCH 1/3] Zone reclaim V3: main patch
Message-Id: <Pine.LNX.4.62.0512081531150.31342@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208210850.GS11190@wotan.suse.de> <Pine.LNX.4.62.0512081320200.30786@schroedinger.engr.sgi.com>
 <20051208225102.GW11190@wotan.suse.de> <Pine.LNX.4.62.0512081514510.31246@schroedinger.engr.sgi.com>
 <20051208232827.GZ11190@wotan.suse.de>
In-Reply-To: <20051208232827.GZ11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>, discuss@x86-64.org

On Fri, 9 Dec 2005, Andi Kleen wrote:

> > My experience is that at 20 systems do not need zone reclaim yet.
> 
> I really cannot confirm your experience here.

Maybe the meaning of these numbers varies? I know that 10 is a local 
access but the assumption in include/linux/numa.h that 20 is a remote 
access is probably already a guess.

I know that our Altix machines seem to use 10 for a local and 20 for 
nonlocal but same box. The distances then increase from there.

