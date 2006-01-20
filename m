From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Fri, 20 Jan 2006 17:31:58 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601200931.58281.jbarnes@virtuousgeek.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com> <200601191818.43157.jbarnes@virtuousgeek.org> <20060120132650.GA4272@sgi.com>
In-Reply-To: <20060120132650.GA4272@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Friday, January 20, 2006 5:26 am, Jack Steiner wrote:
> I don't think calling mmiob() directly would work. In order to make
> CONFIG_IA64_GENERIC work, the call to mmiob() needs to be underneath a
> platform vector. Using ia64_platform_is() would also work but I think
> a platform vector is cleaner.

mmiowb is already a platform vector on ia64, so I think you're ok there.

> A second reason for an arch_task_migrate() instead of a specific
> mmiob() is to provide a hook for a future platform that require
> additional work to be done when a task migrates.

What does the new platform require (just curious)?

Jesse
