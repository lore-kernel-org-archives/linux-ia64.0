From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 21:18:36 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <Pine.LNX.4.64.0711271316110.4590@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>  <20071127001430.083503280@sgi.com>
  <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com> 
 <Pine.LNX.4.64.0711271014550.2310@schroedinger.engr.sgi.com>
 <ed5aea430711271310i144c005cj25101b7dd6b0d6d9@mail.gmail.com>
In-Reply-To: <ed5aea430711271310i144c005cj25101b7dd6b0d6d9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Tue, 27 Nov 2007, David Mosberger-Tang wrote:

> Uniformity for the sake of uniformity?  The small data addressing is
> really elegant and I don't think it should be dropped just for the
> sake of uniformity.

Uniformity for the sake of code size reduction and easier maintenance. 

Yes I think it would be great to have this feature on all arches if 
possible. If someone could work with the gcc /linker folks to get this 
done that would be great.

But the feature has been removed from gcc and so its not usable for IA64 
with a current compiler anymore. This is basically removing useless code.


