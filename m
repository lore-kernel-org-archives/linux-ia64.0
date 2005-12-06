From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Dec 2005 01:21:19 +0000
Subject: RE: Reading /proc/stat is slooow
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05204878@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I just tried CONFIG_NR_CPUS24 ... and I don't see anything
>like a 20ms delay on 2.6.15-rc5.  How many actual cpus on your
>machine (I only have two on the machine where I tested)?

Ah ... but I didn't have CONFIG_HOTPLUG_CPU set ... so my
cpu_possible_map will have only had the two bits set for the
two cpus that exist in my system.  So I was only allocating
a small buffer in stat_open() [which is my best guess for why
you see more time ... with NR_CPUSQ2 you are kmalloc'ing
a big hunk of memory].

With cpu hotplug and NR_CPUS24 I now see 53ms for the first
of the reads from /proc/stat (as reported by strace -T).

-Tony
