From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 17 Mar 2021 23:26:28 +0000
Subject: Re: [PATCH 0/1] sched/topology: NUMA distance deduplication
Message-Id: <132937a8-0514-5a62-2897-569187e355a7@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <255d6b5d-194e-eb0e-ecdd-97477a534441@physik.fu-berlin.de>
 <8735wtr2ro.mognet@arm.com>
 <cf4d7277-54a0-8bc7-60fb-9b2f6befb511@physik.fu-berlin.de>
 <87zgz1pmx4.mognet@arm.com> <87wnu5pkib.mognet@arm.com>
In-Reply-To: <87wnu5pkib.mognet@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valentin Schneider <valentin.schneider@arm.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Sergei Trofimovich <slyfox@gentoo.org>, debian-ia64 <debian-ia64@lists.debian.org>

Hi Valentin!

On 3/17/21 9:56 PM, Valentin Schneider wrote:
> On 17/03/21 20:04, Valentin Schneider wrote:
>> Technically it *is* coping with it, it's just dumping the entire NUMA
>> distance matrix in the process... Let me see if I can't figure out why your
>> system doesn't end up with nr_node_ids=1.
>>
> 
> Does the below
> a) compile

Yes.

> b) do anything?

It fixes the problem for me.

Will test Sergei's patch now.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
