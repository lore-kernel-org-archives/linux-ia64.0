From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Tue, 02 Nov 2004 07:36:36 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041102.163636.39153052.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] top level scheduler domain for ia64
Date: Mon, 1 Nov 2004 11:45:44 -0800

> >Maybe, but that will get complex very quickly I think.  Right now we have 
> >three domains on ia64, the cpu domain, the node domain, which contains 
> >several nodes worth of CPUs, and the top level domain, which spans the whole 
> >machine.
> >
> >So there are two questions, how big should the node domain be and should it 
> >span the whole machine (avoiding the need for a top level domain)?  Obviously 
> >the answer is pretty machine specific, and I'm not sure the SLIT helps us 
> >much since its values are arbitrary distance values, not anything concrete.

Right, but if SLIT is implemented in real firmware (not a fake),
the numbers should have some meanings to describe how the machine
is configured.

For machines which have tree-like hierarchy NUMA, the SLIT table
can help enough to construct scheduling domains (like NEC's, and
I suppose Superdome is similar) and fits well for the sched-domain
scheduler.

The problem is that there can be other forms of topology.
It may be hard to derive its actual connection only with SLIT.
Quoting a SLIT example from the ACPI spec 3.0...

domain [0] [1] [2] [3]
   [0]  10  15  20  18
   [1]  15  10  16  24
   [2]  20  16  10  12
   [3]  18  24  12  10

This is an example which is not real, but it's possible
from the viewpoint of the ACPI spec;)
For this case, it's very hard to say it's worth making other 3
levels of scheduling domains above the cpu domain.

The userspace adjustment which Nanhai proposed does not work
for booting the 512-way Altix anyway (if we remove the node
domain from the generic kernel).

I think the short-term solution is to make the boot-time parameter
like Jesse said to control the creation and span size of the
node domain and see what is necessary next.

---
Takayoshi Kochi
