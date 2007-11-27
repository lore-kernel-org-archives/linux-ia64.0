From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Tue, 27 Nov 2007 05:20:12 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for per cpu access
Message-Id: <ed5aea430711262120p45bb5b2t1b16872e74547369@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>
	 <20071127001430.083503280@sgi.com>
In-Reply-To: <20071127001430.083503280@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On 11/26/07, Christoph Lameter <clameter@sgi.com> wrote:
> The model(small) attribute is not supported by gcc 4.X. The tests
> will always be negative today.

What was the rationale for removing this attribute?

  --david
