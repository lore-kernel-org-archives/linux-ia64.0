From: Doug Chapman <doug.chapman@hp.com>
Date: Tue, 04 Nov 2008 20:35:30 +0000
Subject: Re: [REGRESSION] Minimize per_cpu reservations patch causes NULL
Message-Id: <1225830930.13942.10.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1225830514.13942.8.camel@localhost.localdomain>
In-Reply-To: <1225830514.13942.8.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2008-11-04 at 15:28 -0500, Doug Chapman wrote:
> It appears the intent of calling per_cpu_scan_finalize() at the
> current
> location is that it needs to be called prior to find_memory().  The
> "Minimize
> per_cpu reservations." patch changes code in arch/ia64/mm/discontig.c
> which
> sets up the per-cpu datastructures to only set those up for CPUs in
> early_cpu_possible_map.

Correction on this bit,  it isn't find_memory() it is cpu_init() which
calls per_cpu_init() however the general problem is the same.

- Doug


