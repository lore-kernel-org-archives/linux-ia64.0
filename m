From: Robin Holt <holt@sgi.com>
Date: Wed, 25 Mar 2009 01:21:01 +0000
Subject: Re: kernel unaligned accesses on 2.6.29.
Message-Id: <20090325012101.GC8908@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090324172856.GA8908@sgi.com> <20090325011418.GB8908@sgi.com>
In-Reply-To: <20090325011418.GB8908@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chuck Lever <chuck.lever@oracle.com>, tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Mar 24, 2009 at 08:14:18PM -0500, Robin Holt wrote:
> Had a few minutes to look around.
...
> This one is:
> 	u64 *p = (u64 *)&nsm->sm_priv.data;
> 	...
> 	*p = (unsigned long)nsm;
...
> >     e3d0:       0a 60 28 1c 8d 39       [MMI]       cmp4.eq p12,p13,r14;;
> >     e3d6:       00 a8 95 30 23 00                   st8 [r37]=r53
> 

Well, that was easy.  This is the store part of
	*p++ = timespec_to_ns(&ts);

Again, comes down to &nsm->sm_priv.data not being aligned.

Robin
