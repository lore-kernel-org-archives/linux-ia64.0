From: Andrew Morton <akpm@osdl.org>
Date: Wed, 15 Feb 2006 06:10:55 +0000
Subject: Re: [patch 2/2] Count disabled cpus as potential hot-pluggable CPUs
Message-Id: <20060214221055.5a6be03d.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060214230622.472226988@csdlinux-2.jf.intel.com>
In-Reply-To: <20060214230622.472226988@csdlinux-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj <ashok.raj@intel.com> wrote:
>
> +	printk(KERN_INFO "SMP: Allowing %d CPUs, %d hotplug CPUs\n",
>  +		possible,
>  +	        max_t(int, additional_cpus, 0));

I think a plain old max() would suffice here?
