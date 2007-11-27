From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 22:02:08 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <Pine.LNX.4.64.0711271401350.4803@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>  <20071127001430.083503280@sgi.com>
  <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com> 
 <Pine.LNX.4.64.0711271014550.2310@schroedinger.engr.sgi.com> 
 <ed5aea430711271310i144c005cj25101b7dd6b0d6d9@mail.gmail.com> 
 <Pine.LNX.4.64.0711271316110.4590@schroedinger.engr.sgi.com>
 <ed5aea430711271327l1644750dm363f846a23b1cce5@mail.gmail.com>
In-Reply-To: <ed5aea430711271327l1644750dm363f846a23b1cce5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Tue, 27 Nov 2007, David Mosberger-Tang wrote:

> Code-size reduction?  You must be talking *source* code size
> reduction.  Surely the small-data access-method decreases object code
> size.

Yes source code reduction. I just added the attribute back but in such a 
way that any arch can add attributes to per cpu definitions.

