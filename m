From: Robin Holt <holt@sgi.com>
Date: Thu, 19 Aug 2004 19:48:34 +0000
Subject: Re: calling oem sal functions
Message-Id: <20040819194834.GE1313@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4124E222.2080105@intel.com>
In-Reply-To: <4124E222.2080105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 19, 2004 at 07:21:02PM +0100, Christoph Hellwig wrote:
> On Thu, Aug 19, 2004 at 01:18:03PM -0500, Robin Holt wrote:
> > If you make them GPL, it makes the call useless to SGI.  Some of our
> > tests suites have the problem description we are testing for and the
> > resolution.  This may include vendor specific or customer specific
> > data which is not disclosable.  Some of the vendor specific tests are
> > likewise covered by NDA.  I understand you would love to have
> > everything _GPL, but that is unreasonable.
> 
> Huh?  As long as you use your testsuite only internally the GPL doesn't
> matter.  It only kicks in as soon as you distribute something.

The test suites are part of our online diagnostics.  We normally have the
field support or customer run the diagnostics to identify the source
of the problem.

> 
> > Tony, please carefully consider the _GPL.
> 
> This is talking directly to the SAL layer, something that should
> be reserved to OS internals.

IIRC, the SAL calls that diags make do stuff like change hardware error
timeout settings, hardware request queue sizes, voltage thresholds,
and retry limits so that even slightly marginal hardware becomes extermely
likely to fail.

Userland then uses normal kernel mechanism to excercise the portion
under test (eg: ping-pong a cacheline between two nodes) to attempt to
force an error.

All the error indications we are looking for use the normal kernel
paths.  We are just setting the hardware up for the maximum probability
for failure.

Again Tony, please consider carefully the effect of putting _GPL on
these exports.

Thanks,
Robin
