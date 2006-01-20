From: Jack Steiner <steiner@sgi.com>
Date: Fri, 20 Jan 2006 19:00:59 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060120190059.GB6788@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com> <200601191818.43157.jbarnes@virtuousgeek.org> <20060120132650.GA4272@sgi.com> <200601200931.58281.jbarnes@virtuousgeek.org>
In-Reply-To: <200601200931.58281.jbarnes@virtuousgeek.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: Brent Casavant <bcasavan@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

> > A second reason for an arch_task_migrate() instead of a specific
> > mmiob() is to provide a hook for a future platform that require
> > additional work to be done when a task migrates.
> 
> What does the new platform require (just curious)?
> 
> Jesse

Sorry, can't say. Rejoin SGI & I'll tell you :-)

---
Jack 


