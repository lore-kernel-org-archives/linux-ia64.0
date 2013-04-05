From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 05 Apr 2013 21:54:39 +0000
Subject: Re: [PATCH v3 17/22] x86, ACPI, numa, ia64: split SLIT handling out
Message-Id: <CA+8MBbJMk2w77VGBswoYCEKQZ4HTC9jBhWun5UzGLOj15Nqrmg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365119186-23487-1-git-send-email-yinghai@kernel.org>
	<1365119186-23487-18-git-send-email-yinghai@kernel.org>
In-Reply-To: <1365119186-23487-18-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <yinghai@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi <linux-acpi@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thu, Apr 4, 2013 at 4:46 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> It should not break ia64 by replacing acpi_numa_init with
> acpi_numa_init_srat/acpi_numa_init_slit/acpi_num_arch_fixup.

You are right - it doesn't break ia64.  All my test configs still
build.  Machines both with and without NUMA still boot and
nothing strange happens.

Tested-by: Tony Luck <tony.luck@intel.com>
