From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Date: Fri, 06 Apr 2007 17:48:04 +0000
Subject: Re: [PATCH] ia64: Fix CPU freq displayed in /proc/cpuinfo
Message-Id: <20070406174804.GA23889@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070406170449.GA21441@linux-os.sc.intel.com>
In-Reply-To: <20070406170449.GA21441@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 06, 2007 at 10:29:03AM -0700, Luck, Tony wrote:
> 
> +		   "cpu MHz    : %lu.%03lu\n"
>  		   "itc MHz    : %lu.%06lu\n"
> 
> 
> Why did you cut the precision of cpu MHz back to 1Khz?  Is the
> extra precision not-warranted, or is this just to be more like
> other architectures?

That is because we try to get this from cpufreq and cpufreq
has this info in kHz.
 
> Should we do the same for itc MHz to treat both evenly?

Not sure about this. I guess we can retain it the way it is as it is
something directly coming from hardware. CPU frequency in turn can come
cpufreq or acpi tables. ACPI table will reduce this further as it
always gives the info in MHz (on processors that has ACPI
based P-states support).

Thanks,
Venki
