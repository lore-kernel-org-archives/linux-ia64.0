From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Feb 2008 03:50:11 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <47A92E73.6050504@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> Then, I suppose we need a CPU_UP_PREPARE callback to allocate memory
> before hot-added CPU enters cpu_init().

Ah, we cannot allocate bootmem later, so it would be better to make
the callback to return NOTIFY_BAD if (!__per_cpu_mca[hcpu]).

Thanks,
H.Seto

