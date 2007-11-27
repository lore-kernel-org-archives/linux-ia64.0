From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 18:15:29 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <Pine.LNX.4.64.0711271014550.2310@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>  <20071127001430.083503280@sgi.com>
 <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com>
In-Reply-To: <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Mosberger-Tang <dmosberger@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Mon, 26 Nov 2007, David Mosberger-Tang wrote:

> On 11/26/07, Christoph Lameter <clameter@sgi.com> wrote:
> > The model(small) attribute is not supported by gcc 4.X. The tests
> > will always be negative today.
> 
> What was the rationale for removing this attribute?

The code is then similar across all architectures and can be moved into 
generic code.

