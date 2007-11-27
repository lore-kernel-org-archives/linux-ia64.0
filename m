From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 27 Nov 2007 18:17:14 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for
Message-Id: <Pine.LNX.4.64.0711271016500.2310@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com> <20071127001430.083503280@sgi.com>
 <jehcj83uir.fsf@sykes.suse.de>
In-Reply-To: <jehcj83uir.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Tue, 27 Nov 2007, Andreas Schwab wrote:

> Christoph Lameter <clameter@sgi.com> writes:
> 
> > The model(small) attribute is not supported by gcc 4.X.
> 
> Which gcc 4.X are you talking about?

All. Last gcc that supported this was 3.4.

