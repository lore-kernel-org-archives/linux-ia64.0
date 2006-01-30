From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 30 Jan 2006 19:24:38 +0000
Subject: Re: boot-time slowdown for measure_migration_cost
Message-Id: <20060130192438.GA29129@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601271403.27065.bjorn.helgaas@hp.com> <20060130172140.GB11793@elte.hu> <20060130185301.GA4622@agluck-lia64.sc.intel.com>
In-Reply-To: <20060130185301.GA4622@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>


* Luck, Tony <tony.luck@intel.com> wrote:

> Doing this drops the time to compute the value from 15.58s to 10.39s,=20
> while the value of migration_cost changes from 10112 to 9909.
>
> > - in kernel/sched.c, change this line:
> >                 size =3D size * 20 / 19;
> >   to:
> >                 size =3D size * 10 / 9;
>
> Doing this instead of changing ITERATIONS makes the computation take=20
> 7.79s and the computed migration_cost is 9987.
>
> Doing both gets the time down to 5.20s, and the migration_cost=9990.

ok, that's good enough i think - we could certainly do the patch below=20
in v2.6.16.

> On the plus side Prarit's results show that this time isn't scaling=20
> with NR_CPUS ... apparently just cache size and number of domains are=20
> significant in the time to compute.

yes, this comes from the algorithm, it only computes once per distance=20
(and uses the cached value from then on), independently of the number of=20
CPUs.

	Ingo

---
reduce the amount of time the migration cost calculations cost during=20
bootup.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

--- linux/kernel/sched.c.orig
+++ linux/kernel/sched.c
@@ -5141,7 +5141,7 @@ static void init_sched_build_groups(stru
 #define SEARCH_SCOPE		2
 #define MIN_CACHE_SIZE		(64*1024U)
 #define DEFAULT_CACHE_SIZE	(5*1024*1024U)
-#define ITERATIONS		2
+#define ITERATIONS		1
 #define SIZE_THRESH		130
 #define COST_THRESH		130
=20
@@ -5480,9 +5480,9 @@ static unsigned long long measure_migrat
 				break;
 			}
 		/*
-		 * Increase the cachesize in 5% steps:
+		 * Increase the cachesize in 10% steps:
 		 */
-		size =3D size * 20 / 19;
+		size =3D size * 10 / 9;
 	}
=20
 	if (migration_debug)
