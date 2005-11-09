From: Rohit Seth <rohit.seth@intel.com>
Date: Wed, 09 Nov 2005 00:22:40 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <1131495760.6542.2.camel@akash.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-11-09 at 00:58 +0100, Gerald Pfeifer wrote:
> On Tue, 8 Nov 2005, Rohit Seth wrote:
> > I agree with you completely about OSV certification part.  And SuSE is
> > again a good example here, they have a released kernel with 64K page
> > size.  There is no reason why end customer should not be using this
> > bigger page kernel when desired.
> 
> Unfortuantely, I'm pretty sure that if you run such a kernel and call
> $BIGISV for support you'll find yourself in troubles. :-(
> 

> OSVs and ISVs, on the other hand, usually prefer to only test and harden 
> and qualify/certify a single kernel (which is why Dan's approach to Xen/ia64
> looks quite appealing).
> 

Going by your first argument, the first thing ISV/OSV will in this case
ask the end customer to knock of all the extra/special command line
options used...

-rohit

