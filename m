From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Jan 2002 23:26:58 +0000
Subject: RE: [Linux-ia64] [PATCH]  Support for alternative kernel profiler
Message-Id: <marc-linux-ia64-105590698805802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805742@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805742@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We don't currently have any way for different software packages
to share the performance counters, so it's very likely that there
would be interactions with Stephane's PMU code (e.g. I rewrite
cr.pmv to a new vector and re-write all of the pmc[] and pmd[]
registers for my own purposes ... this will upset Stephane's code,
similarly my code does not expect anyone else to touch any PMU
registers, or fiddle with psr.pp/dcr.pp).

It would probably be safest to turn off CONFIG_PERFMON in a kernel
that is going to load an alternate profiler ... my profiler seems
to cope ok provided nobody calls sys_perfmonctl().

-Tony

David Mosberger wrote:
> I'd like Stephane to take a look at this patch and see whether there
> are any potential bad interactions with the PMU code he is working on
> (due to the manipulation of the psr.pp bit).  Other than that, the
> patch looks good to me.

