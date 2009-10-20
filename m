From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 07:11:38 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADD62AA.8060503@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <20091020061557.GE8550@elte.hu> <alpine.LSU.2.00.0910200820500.8582@wotan.suse.de> <20091020063555.GJ8550@elte.hu>
In-Reply-To: <20091020063555.GJ8550@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Kosina <jkosina@suse.cz>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Ingo Molnar a =E9crit :
=20
> Still looks like a bug if it causes a breakage (linker error) on IA64,=20
> and if the 'fix' (i'd call it a workaround) causes a (small but nonzero) =

> performance regression on other architectures.
>=20

True, but this also save some amount of ram for some distro kernels.

If we keep this static NR_CPUS thing, we might be able to free
the end of table, for other per_cpu users ?

if (nr_cpus_ids < NR_CPUS) {
	per_cpu_free_static_zone(&update_shares_data[nr_cpus_ids],
				 sizeof(long)*(NR_CPUS - nr_cpus_ids));
}


