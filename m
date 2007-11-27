From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Tue, 27 Nov 2007 21:27:02 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for per cpu access
Message-Id: <ed5aea430711271327l1644750dm363f846a23b1cce5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>
	 <20071127001430.083503280@sgi.com>
	 <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com>
	 <Pine.LNX.4.64.0711271014550.2310@schroedinger.engr.sgi.com>
	 <ed5aea430711271310i144c005cj25101b7dd6b0d6d9@mail.gmail.com>
	 <Pine.LNX.4.64.0711271316110.4590@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711271316110.4590@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On 11/27/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Tue, 27 Nov 2007, David Mosberger-Tang wrote:
>
> > Uniformity for the sake of uniformity?  The small data addressing is
> > really elegant and I don't think it should be dropped just for the
> > sake of uniformity.
>
> Uniformity for the sake of code size reduction and easier maintenance.

Code-size reduction?  You must be talking *source* code size
reduction.  Surely the small-data access-method decreases object code
size.

  --david
