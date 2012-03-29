From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=  <u.kleine-koenig@pengutronix.de>
Date: Thu, 29 Mar 2012 21:12:27 +0000
Subject: [PATCH 10/17] ia64: mark const init data with __initconst instead of __initdata
Message-Id: <1333055554-31300-10-git-send-email-u.kleine-koenig@pengutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120329211131.GA31250@pengutronix.de>
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel@pengutronix.de, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

As long as there is no other non-const variable marked __initdata in the
same compilation unit it doesn't hurt. If there were one however
compilation would fail with

	error: $variablename causes a section type conflict

because a section containing const variables is marked read only and so
cannot contain non-const variables.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/xen/irq_xen.c |    2 +-
 arch/ia64/xen/irq_xen.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
index 3bb1223..01f479e 100644
--- a/arch/ia64/xen/irq_xen.c
+++ b/arch/ia64/xen/irq_xen.c
@@ -433,7 +433,7 @@ xen_resend_irq(unsigned int vector)
 	(void)resend_irq_on_evtchn(vector);
 }
=20
-const struct pv_irq_ops xen_irq_ops __initdata =3D {
+const struct pv_irq_ops xen_irq_ops __initconst =3D {
 	.register_ipi =3D xen_register_ipi,
=20
 	.assign_irq_vector =3D xen_assign_irq_vector,
diff --git a/arch/ia64/xen/irq_xen.h b/arch/ia64/xen/irq_xen.h
index 26110f3..1778517 100644
--- a/arch/ia64/xen/irq_xen.h
+++ b/arch/ia64/xen/irq_xen.h
@@ -27,7 +27,7 @@ extern void (*late_time_init)(void);
 extern char xen_event_callback;
 void __init xen_init_IRQ(void);
=20
-extern const struct pv_irq_ops xen_irq_ops __initdata;
+extern const struct pv_irq_ops xen_irq_ops __initconst;
 extern void xen_smp_intr_init(void);
 extern void xen_send_ipi(int cpu, int vec);
=20
--=20
1.7.9.1

