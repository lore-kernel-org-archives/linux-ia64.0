From: Tony Luck <tony.luck@intel.com>
Date: Thu, 12 Apr 2012 21:52:48 +0000
Subject: Re: [PATCH] ia64: populate the cmpxchg header with appropriate code
Message-Id: <CA+8MBb+LEqcyGQ+qfmnqzmPEtHeOf=XoR4rtpW9Rz74zU80Mkw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333479610-13321-1-git-send-email-paul.gortmaker@windriver.com>
	<CAP=VYLroi_uGBUmwEE2g=nH2z-oD6nYwo_D+o+QHMtWERP=yvA@mail.gmail.com>
	<CA+8MBbJ-Ub9JtJ+nbMScOfcP6HtAjmQ0qZkWOa6H_3A3VHwz7g@mail.gmail.com>
	<CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
In-Reply-To: <CAA9xbM6vKjhy9LH4f=dQqAKRxjQ=3DpP2_QFL0=fJdx+y47JZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, David Howells <dhowells@redhat.com>, Michel Lespinasse <walken@google.com>

I think that problem with the futex change is not with the ia64 inline
parts ... but
with the code that decides whether to enable them.  Try this
(white-space damaged,
but not intended for prime-time) patch:

diff --git a/kernel/futex.c b/kernel/futex.c
index e2b0fb9..9a00bf8 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2722,7 +2722,9 @@ static int __init futex_init(void)
         * implementation, the non-functional ones will return
         * -ENOSYS.
         */
+#ifndef CONFIG_IA64
        if (cmpxchg_futex_value_locked(&curval, NULL, 0, 0) = -EFAULT)
+#endif
                futex_cmpxchg_enabled = 1;

        for (i = 0; i < ARRAY_SIZE(futex_queues); i++) {


IA64 doesn't return a -EFAULT when we poke at the supposedly invalid user
address of "NULL" because we map a special page to catch prefetch references
so that loops like "for (p = something; p != NULL; p = p->next) { use
p->field }" don't
do unpleasant thinks when the pre-fetcher dereferences the NULL "p".

This patch enables the futexttest suite to run ... perhaps it will help
with the other problems too?

-Tony
