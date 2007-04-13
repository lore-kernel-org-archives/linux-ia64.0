From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date: Fri, 13 Apr 2007 04:43:40 +0000
Subject: Re: [KJ][PATCH 02/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <20070413043140.GA9431@arun.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412203140.GB9353@arun.site> <20070412211334.GA5892@intel.com>
In-Reply-To: <20070412211334.GA5892@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de

On 14:13 Thu 12 Apr     , Luck, Tony wrote:
> On Fri, Apr 13, 2007 at 02:01:40AM +0530, Milind Arun Choudhary wrote:
> > -	size = ROUNDUP(size, iovp_size);
> > +	size = ALIGN(size, iovp_size);
> 
> Why is "ALIGN" better than "ROUNDUP"?  I can't see any point
> to this change.
Its a janitorial work. I'm trying to celanup 
all the corners where ROUNDUP/DOWN & likes are defined.
Kernel.h currently has macros like ALIGN roundup DIV_ROUND_UP.
in this patch series I've added ALIGN_DOWN & round_down
[waiting for comments on the same.]

So as ALIGN macro does the same work as ROUNDUP,
      is at a common place
      & is accessible to everyone
it should be used instead...i think

-- 
Milind Arun Choudhary
