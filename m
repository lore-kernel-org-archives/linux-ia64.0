From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 06 Apr 2005 05:56:00 +0000
Subject: RE: [Gelato-technical] Serious performance degradation on a RAID withkernel 2.6.11
Message-Id: <200504060556.j365u0g24048@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16978.62532.841151.100745@napali.hpl.hp.com>
In-Reply-To: <16978.62532.841151.100745@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 05, 2005 at 09:45:34PM -0700, David Mosberger wrote:
>
> Did you compile the driver as a module?


Duraid Madina wrote on Tuesday, April 05, 2005 9:53 PM
> Nope. You're not seeing the problem?

That is the reason for the performance problem.  And this is definitely
*not* ia64 specific.  See this discussion which started with performance
problem seen on opteron and reproduced on DELL machine as well.
http://marc.theaimsgroup.com/?t1028927300002&r=1&w=2

The changeset that david pointed out is the right fix.  Or you can just
take the small patch I posted in the above thread.

- Ken


