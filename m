From: Robin Holt <holt@sgi.com>
Date: Wed, 06 Feb 2008 01:34:47 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080206013447.GD3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2008 at 09:30:17AM +0900, Hidetoshi Seto wrote:
> Russ Anderson wrote:
>> The MCA code allocates bootmem memory for NR_CPUS, regardless
>> of how many cpus the system actually has.
>
> So... how about using num_possible_cpus() instead?

num_possible_cpus() is not initialized until after this code is run for
the first time.

Thanks,
Robin
