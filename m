From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 10 Mar 2004 18:17:50 +0000
Subject: Re: IA32 programs make kernel stall on IPF machine when CONFIG_PREEMPT is enabled
Message-Id: <20040310181750.GA9749@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B05154D94@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B05154D94@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 09, 2004 at 08:40:00PM -0800, Zhang, Yanmin wrote:
> There is a bug in base kernel 2.6.3. When CONFIG_PREEMPT is enabled, all
> IA32 programs will make kernel stall on IPF machines.

This bug was introduced by the NPTL for ia32 patch. The fix looks good to me. 

Thanks!

	-Arun
