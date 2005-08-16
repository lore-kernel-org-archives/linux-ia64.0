From: vamsi krishna <vamsi.krishnak@gmail.com>
Date: Tue, 16 Aug 2005 21:39:54 +0000
Subject: Re: Multiple virtual address mapping for the same code on IA-64 linux kernel.
Message-Id: <3faf0568050816142715f14c2c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F04294461@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F04294461@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello All,

Really thankful for your inputs!

> Itanium instruction set is not as compact as some other architectures,
> so the same program will typically require more bytes of code.

I stopped the program on both amd64 machine and ia64 machine and
grepped the values from /proc/<>/status and found the following.

<----Linux IPF----------->
VmSize:   126304 kB
VmLck:         0 kB
VmRSS:      6352 kB
VmData:    19696 kB
VmStk:        16 kB
VmExe:     97760 kB
VmLib:      3152 kB
<------------------------>

<------AMD64------------->
VmSize:   100432 kB
VmLck:         0 kB
VmRSS:      2828 kB
VmData:    24428 kB
VmStk:       264 kB
VmExe:     62848 kB
VmLib:      3048 kB
<----------------------->

Seems like most of core size(VmSize) on ipf (126MB) is coming from the
code size(VmExe) i.e 97MB. While the code size is just 62MB on amd64.

Looks like IA-64 wastes a lot of VM due to big instruction sizes, so
big instruction sizes will improve performance ? compared small
instruction sizes? , but fetching big instructions surely takes time
compared to small, this may be the reason why amd64 is the fasttest
64-bit process ?

Thanks a lot!
Vamsi
