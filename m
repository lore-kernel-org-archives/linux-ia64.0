From: Tony Luck <tony.luck@intel.com>
Date: Tue, 14 Feb 2012 23:00:43 +0000
Subject: Re: [PATCH] Avoid mask based num_possible_cpus and num_online_cpus -v5
Message-Id: <CA+8MBbLZhacoWj03bLciA-r+wrfyW03C3QrXgWuBrM3axBdGAg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CABeCy1aPp4=v90v_wAsw-KWDwNs59CwwYSJ-36+4t8kMuCaK0w@mail.gmail.com>
	<1328055439-9441-1-git-send-email-venki@google.com>
	<20120201140125.c656df41.akpm@linux-foundation.org>
	<87d39xj955.fsf@rustcorp.com.au>
	<CA+8MBbJcTgj7X-7RZAgWk8a3Qyaz1FxFzu3ZLk-8LHKD7M8h-Q@mail.gmail.com>
	<4F3971A1.5010305@linux.vnet.ibm.com>
	<4F39763D.3070609@linux.vnet.ibm.com>
	<CA+8MBbLR+rcJqe2z9tAt7Oav4wqgZA3k8Te6zcXNOs+zv2wAaA@mail.gmail.com>
	<87wr7pbwbz.fsf@rustcorp.com.au>
	<4F3AD3B6.8070409@linux.vnet.ibm.com>
In-Reply-To: <4F3AD3B6.8070409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Tue, Feb 14, 2012 at 1:35 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> Right. And we should also ensure that nobody messes directly with
> cpu_possible_map as well. I have written up a patch for ia64 (see below).
> Sorry, I haven't even compile tested it - I neither have the toolchain no=
r the
> hardware. I hope it works!

Thanks for doing this - compiles and seems to work.

Tested-by: Tony Luck <tony.luck@intel.com>

Can we get this added to the series - so it gets applied along with
Venki's patch.

> =A00 files changed, 0 insertions(+), 0 deletions(-)

I think your patch generation script needs some attention - I see
 arch/ia64/kernel/setup.c   |    2 +-
 arch/ia64/kernel/smp.c     |    2 +-
 arch/ia64/kernel/smpboot.c |   12 ++++++------
 3 files changed, 8 insertions(+), 8 deletions(-)

> @@ -609,7 +609,7 @@ smp_prepare_cpus (unsigned int max_cpus)
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We have the boot CPU online for sure.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 cpu_set(0, cpu_online_map);
> + =A0 =A0 =A0 set_cpu_online(0, true);
> =A0 =A0 =A0 =A0cpu_set(0, cpu_callin_map);
>
> =A0 =A0 =A0 =A0local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;

Generic code has already marked cpu 0 online ... so this one could
just be dropped (and the preceding comment too). Though it does no
harm to set it again.

-Tony
