From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 07 Jun 2004 16:41:49 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <1086626508.28074.1.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-06-07 at 07:08, Ashok Raj wrote:plugging.
> +		if (systemcfg->platform = PLATFORM_PSERIES_LPAR)
> +			cpu->no_control=1;

That condition is also inverted.  Should read:

if (systemcfg->platform != PLATFORM_PSERIES_LPAR)
	cpu->no_control = 1;



-- Dave

