From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 19 Aug 2004 18:21:02 +0000
Subject: Re: calling oem sal functions
Message-Id: <20040819192102.A11978@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4124E222.2080105@intel.com>
In-Reply-To: <4124E222.2080105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 19, 2004 at 01:18:03PM -0500, Robin Holt wrote:
> If you make them GPL, it makes the call useless to SGI.  Some of our
> tests suites have the problem description we are testing for and the
> resolution.  This may include vendor specific or customer specific
> data which is not disclosable.  Some of the vendor specific tests are
> likewise covered by NDA.  I understand you would love to have
> everything _GPL, but that is unreasonable.

Huh?  As long as you use your testsuite only internally the GPL doesn't
matter.  It only kicks in as soon as you distribute something.

> Tony, please carefully consider the _GPL.

This is talking directly to the SAL layer, something that should
be reserved to OS internals.
