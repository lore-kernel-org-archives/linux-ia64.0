From: Erich Focht <efocht@hpce.nec.com>
Date: Thu, 04 Nov 2004 15:31:42 +0000
Subject: Re: Externalize SLIT table
Message-Id: <200411041631.42627.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com> <20041104141337.GA18445@sgi.com>
In-Reply-To: <20041104141337.GA18445@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jack Steiner <steiner@sgi.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thursday 04 November 2004 15:13, Jack Steiner wrote:
> I think it would also be useful to have a similar cpu-to-cpu distance
> metric:
> =A0=A0=A0=A0=A0=A0=A0=A0% cat /sys/devices/system/cpu/cpu0/distance
> =A0=A0=A0=A0=A0=A0=A0=A010 20 40 60=20
>=20
> This gives the same information but is cpu-centric rather than
> node centric.

I don't see the use of that once you have some way to find the logical
CPU to node number mapping. The "node distances" are meant to be
proportional to the memory access latency ratios (20 means 2 times
larger than local (intra-node) access, which is by definition 10).=20
If the cpu_to_cpu distance is necessary because there is a hierarchy
in the memory blocks inside one node, then maybe the definition of a
node should be changed...

We currently have (at least in -mm kernels):
       % ls /sys/devices/system/node/node0/cpu*
for finding out which CPUs belong to which nodes. Together with
       /sys/devices/system/node/node0/distances
this should be enough for user space NUMA tools.

Regards,
Erich

