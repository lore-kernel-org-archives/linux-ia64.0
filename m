From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 06 Apr 2005 23:45:54 +0000
Subject: Re: tiger_defconfig build fails for 2.6.12-rc2-mm1
Message-Id: <Pine.LNX.4.58.0504061641420.27944@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050405165047.A21553@unix-os.sc.intel.com>
In-Reply-To: <20050405165047.A21553@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 6 Apr 2005, Andrew Morton wrote:

> Oh well, I'll drop it for now.  Christoph, could you please double-check
> everything (including the x86 mmx thing) and resend?

Drop it for good. It only showed minimal benefit on ia64 (however, 3% on
i386). I am working on something different that uses temporal and
nontemporal stores for clearing pages. It will add a clear_cold function
that can zero higher order pages using nontemporal stores in order to
avoid thrashing the cache. No clear_page/clear_pages anymore.
