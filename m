From: "John Hawkes" <hawkes@sgi.com>
Date: Mon, 08 Nov 2004 17:31:06 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <00ba01c4c5b8$bb659eb0$6700a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Jesse Barnes" <jbarnes@engr.sgi.com>
> > So tell me who wants a value other than 6, and what is the value
> > that they want?  I was hoping for some more specific advice in
> > the kernel-parameters.txt file.  What's a good choice for a 16-node
> > machine?  For a 128-node machine?
>
> I don't know.  The original value I chose was 4, but I think Nick changed it
> to 6 to get more overlap.  Any ideas John?

I haven't been able to get enough reliably reproducible performance numbers
using the recent -mm kernels to allow me to experiment with different
nodes-per-domain values.  Using 6 and having an occasionally load-balancing
umbrella covering all the CPUs in the system seems to behave reasonably for
64p and above.  I just haven't tried other values, other than once trying 32
and without that all-CPU umbrella, and that performance was bad.

John Hawkes

