From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 27 Mar 2007 17:53:10 +0000
Subject: Re: [PATCH] - Speed up boot - skip unnecessary clock calibration
Message-Id: <20070327175309.GE15035@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327132953.GA14401@sgi.com>
In-Reply-To: <20070327132953.GA14401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 27, 2007 at 08:29:54AM -0500, Jack Steiner wrote:
> +	if (local_cpu_data->itc_freq != per_cpu(cpu_info, cpuid - 1).itc_freq ||
> +			local_cpu_data->proc_freq != per_cpu(cpu_info, cpuid - 1).proc_freq ||
> +	    		local_cpu_data->features != per_cpu(cpu_info, cpuid - 1).features ||
> +	    		local_cpu_data->revision != per_cpu(cpu_info, cpuid - 1).revision ||
> +	    		local_cpu_data->family != per_cpu(cpu_info, cpuid - 1).family ||
> +	    		local_cpu_data->archrev != per_cpu(cpu_info, cpuid - 1).archrev ||
> +	    		local_cpu_data->model != per_cpu(cpu_info, cpuid - 1).model)
> +		calibrate_delay();

If you use a temporary variable, you improve speed a little, and you
don't exceed 80 columns:

+	struct cpuinfo_ia64 *last_cpu_info = cpu_data(cpuid - 1);
+	struct cpuinfo_ia64 *this_cpu_info = local_cpu_data;
+	if (last_cpu_info->itc_freq != this_cpu_info->itc_freq ||
+	    last_cpu_info->proc_freq != this_cpu_info->proc_freq ||
+	    last_cpu_info->features != this_cpu_info->features ||
+	    last_cpu_info->revision != this_cpu_info->revision ||
+	    last_cpu_info->family != this_cpu_info->family ||
+	    last_cpu_info->archrev != this_cpu_info->archrev ||
+	    last_cpu_info->model != this_cpu_info->model)
+		calibrate_delay();

