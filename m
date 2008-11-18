From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 18 Nov 2008 07:12:55 +0000
Subject: Re: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <20081118071255.GN1617@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 18, 2008 at 08:06:53AM +0100, Petr Tesarik wrote:
> Well, then let's make it a boot option (or a sysctl). The default must
> be psr.ac = 1, but if the admin sees "unaligned access" messages and
> knows that there is no way of getting a (timely) fix for that particular
> production system, s/he should be able to turn them off.

Or how about ia64 does what every other Linux port does and turn off
alignment warnings altogether?  Are they *particularly* expensive
on Itanium?  I bet they aren't.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
