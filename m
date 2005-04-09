From: Grant Grundler <iod00d@hp.com>
Date: Sat, 09 Apr 2005 00:46:03 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <20050409004603.GJ3844@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 08, 2005 at 04:15:43PM -0700, Matt Mackall wrote:
> > static inline int
> > fls (int x)
> > {
> > 	if (!x)
> > 		return 0;
> > 	return ia64_fls((unsigned int) x) + 1;
> > }
> 
> I was trying desperately to avoid the branch, as I understand there
> are issues there on IA64. 

ia64 will inline this routine (no return branch) and the "if ()" case
will be predicated (which is very efficient).

parisc/et al pay a penalty for un-/mis-predicted branches.
But not as bad a cache miss by a long shot.
Adding "likely()" (or unlikely as approrpiate) can help
mitigate where the compiler doesn't pick the right thing.

grant
