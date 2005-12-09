From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 09 Dec 2005 18:31:34 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <4399CD86.7050205@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> I haven't completed my investigation yet -- the first patch that I 
> submitted was in response to (what appeared to be) a minor issue 
> reported by a colleague at another vendor and as Robin points out, is 
> clearly only the start of the fix.
> 

Here I am replying to myself :p

hp/sim/simserial.c:1038:__initcall(simrs_init);
hp/sim/simeth.c:532:__initcall(simeth_probe);

This code has the ia64_platform_is wrapper -- and could be mod'ded as previously 
suggested.

P.

> P.
> 
> 

