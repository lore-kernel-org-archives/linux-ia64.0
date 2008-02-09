From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 09 Feb 2008 00:09:24 +0000
Subject: RE: [PATH] Reduce per_cpu allocations to minimum needed for bootV3.
Message-Id: <1FE6DD409037234FAB833C420AA843EC8BE785@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080208225015.GK3875@sgi.com>
In-Reply-To: <20080208225015.GK3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Not that I can think of.  The early_cpu_possible_map will be a superset
> of the cpu_possible_map.

It might be a bigger superset than we'd like ... I'm not sure if there
are any hard rules about how SRAT tables are populated.  W.r.t. memory
the entries tend to be broad: "If there is any memory in this range, then
it belongs to this node".  Perhaps cpu entries may exist in the SRAT
without much regard to whether than can actually exist on the platform
that we are executing on.

But perhaps this is enough to solve the worst parts of the problem
here.  Small platforms will only populate SRAT out as far as they
run their product line (32, 64, 128 cpus) ... so a kernel configured
for 4096 cpus would at least limit the wasted allocations to this
figure ... which is still a giant step forward.


>                              If the machine does not have numa acpi
> information, we will default to (currently 4 cpus) and initialize those
> on node 0.  We will then later only set the actual number in the
> cpu_possible_map.  There would be nothing (other than the lacking
> hardware) which differentiates these processors from ones in the
> cpu_possible_map.  If you would like to go with the cpu_possible_map, I
> will happily do some testing with that over the weekend.
>
> Could I get some direction on the number of cpus to define when there
> are no numa tables?  Do you know what the hardware limitation is for
> number of processors on a FSB?

The entries here are logical cpus, yes?  So with Mont{ecito,vale} 4
sockets on the FSB * 2 cores * 2 threads = 16.

I'm not sure that I understand the problems if we have too low a figure
here.  Will we:
1) crash
2) fail to use the cpus extra cpus
3) something else

Looking further ahead ... a single node Tukwila will could have four
sockets * 4 cores * 2 threads = 32.

-Tony

