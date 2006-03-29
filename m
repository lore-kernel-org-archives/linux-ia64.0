From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Mar 2006 23:31:02 +0000
Subject: Re: [RFC][PATCH] avoid creating empty nodes [0/2]
Message-Id: <20060330083102.ab67f4e2.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 29 Mar 2006 08:37:34 -0600
Jack Steiner <steiner@sgi.com> wrote:
> ACPI3.0 will have a way to describe these IO nodes. We have not done the
> design but when ACPI3.0 is available, we intend to make the kernel fully
> aware of IO-only nodes. 
> 

Then, we should set I/O nodes's pxm to pxm_online_map (I added in patch) in 
acpi_numa_arch_fixup() in addition to cpus and memory. But there are no codes
to find available I/O nodes now.
Correct ?

BTW I heared ACPI3.0 can define pxm > 256. If we support it, entire codes should
be rewrote ;(.

-- Kame

