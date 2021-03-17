From: Valentin Schneider <valentin.schneider@arm.com>
Date: Wed, 17 Mar 2021 19:36:27 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <8735wtr2ro.mognet@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
In-Reply-To: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Sergei Trofimovich <slyfox@gentoo.org>, debian-ia64 <debian-ia64@lists.debian.org>


Hi,

On 17/03/21 20:04, John Paul Adrian Glaubitz wrote:
> Hi Valentin!
>
>> As pointed out by Barry in [1], there are topologies out there that struggle to
>> go through the NUMA distance deduplicating sort. Included patch is something
>> I wrote back when I started untangling this distance > 2 mess.
>>
>> It's only been lightly tested on some array of QEMU-powered topologies I keep
>> around for this sort of things. I *think* this works out fine with the NODE
>> topology level, but I wouldn't be surprised if I (re)introduced an off-by-one
>> error in there.
>
> This patch causes a regression on my ia64 RX2660 server:
>
> [    0.040000] smp: Brought up 1 node, 4 CPUs
> [    0.040000] Total of 4 processors activated (12713.98 BogoMIPS).
> [    0.044000] ERROR: Invalid distance value range
> [    0.044000]
>
> The machine still seems to boot normally besides the huge amount of spam. Full message
> log below.
>
> Any idea?
>

Harumph!

The expected / valid distance value range (as per ACPI spec) is
[10, 255] (actually double-checking the spec, 255 is supposed to mean
"unreachable", but whatever)

Now, something in your system is exposing 256 nodes, all of them distance 0
from one another - the spam you're seeing is a printout of

  node_distance(i,j) for all nodes i, j

I see ACPI in your boot logs, so I'm guessing you have a bogus SLIT table
(the ACPI table with node distances). You should be able to double check
this with something like:

$ acpidump > acpi.dump
$ acpixtract -a acpi.dump
$ iasl -d *.dat
$ cat slit.dsl

As for fixing it, I think you have the following options:

a) Complain to your hardware vendor to have them fix the table and ship a
   firmware fix
b) Fix the ACPI table yourself - I've been told it's doable for *some* of
   them, but I've never done that myself
c) Compile your kernel with CONFIG_NUMA=n, as AFAICT you only actually have
   a single node
d) Ignore the warning


c) is clearly not ideal if you want to use a somewhat generic kernel image
on a wide host of machines; d) is also a bit yucky...
