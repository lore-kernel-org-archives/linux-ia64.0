From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 12 Apr 2007 18:38:44 +0000
Subject: Re: [PATCH] - Increase max SSI size
Message-Id: <Pine.LNX.4.64.0704121136520.28159@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412175819.GA9723@sgi.com>
In-Reply-To: <20070412175819.GA9723@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Apr 2007, Jack Steiner wrote:

> -	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
> +	sysfs_cpus = vmalloc(sizeof(struct ia64_cpu) * NR_CPUS);
> +	memset(sysfs_cpus, 0, sizeof(sizeof(struct ia64_cpu) * NR_CPUS));
>  	if (!sysfs_cpus)
>  		panic("kzalloc in topology_init failed - NR_CPUS too big?");

Consider using nr_cpu_ids instead of NR_CPUS. This will allocate a smaller 
array on systems that support just a handful of processors.

