From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 24 Mar 2004 14:34:15 +0000
Subject: Re: 2.4.25 + 040218.diff OOPS
Message-Id: <4643.1080138855@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040320115002.GF21377@louise.pinerecords.com>
In-Reply-To: <20040320115002.GF21377@louise.pinerecords.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mar-23 2004, Tue, 10:12 -0700
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> Can you look up these IPs by hand, since ksymoops doesn't work?

Because IA64 does not distinguish between the address of the function
and the address of the function descriptor.  Sometimes the symbol
points at the function code, sometimes at the descriptor.  It is
impossible to match maps that use the same symbol to point to different
locations.

PPC64 got it right.  They use 'func' for the descriptor and '.func' for
the code body, and are consistent about which is which.  Too late to do
anything about it for IA64, the maps are permanently inconsistent.

