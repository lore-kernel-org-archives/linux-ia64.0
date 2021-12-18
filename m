From: Yury Norov <yury.norov@gmail.com>
Date: Sat, 18 Dec 2021 21:19:59 +0000
Subject: [PATCH 03/17] fix open-coded for_each_set_bit()
Message-Id: <20211218212014.1315894-4-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211218212014.1315894-1-yury.norov@gmail.com>
In-Reply-To: <20211218212014.1315894-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Yury Norov <yury.norov@gmail.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, "Paul E. McKenney" <paulmck@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexey Klimov <aklimov@redhat.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Andy Gross <agross@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Laight <David.Laight@ACULAB.COM>, Dennis Zhou <dennis@kernel.org>, Emil Renner Berthing <kernel@esmil.dk>, Geert Uytterhoeven <geert@linux-m68k.org>, Geetha sowjanya <gakula@marvell.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Hans de Goede <hdegoede@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Ian Rogers <irogers@google.com>, Ingo Molnar <mingo@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Jason Wessel <jason.wessel@windriver.com>, Jens Axboe <axboe@fb.com>, Jiri Olsa <jolsa@redhat.com>, Joe Perches <joe@perches.com>, Jonathan Cameron <jic23@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Lee Jones <lee.jones@linaro.org>, Marc Zyngier <maz@kernel.org>, Marcin Wojtas <mw@semihalf.com>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Nicholas Piggin <npiggin@gmail.com>, Palmer Dabbelt <palmer@dabbelt.com>, Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Russell King <linux@armlinux.org.uk>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Sergey Senozhatsky <senozhatsky@chromium.org>, Solomon Peachy <pizza@shaftnet.org>, Stephen Boyd <sboyd@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Subbaraya Sundeep <sbhatta@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Sunil Goutham <sgoutham@marvell.com>, Tariq Toukan <tariqt@nvidia.com>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Vineet Gupta <vgupta@kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>, bcm-kernel-feedback-list@broadcom.com, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

Mellanox driver has an open-coded for_each_set_bit(). Fix it.

Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index e10b7b04b894..c56d2194cbfc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1994,21 +1994,16 @@ static void mlx4_allocate_port_vpps(struct mlx4_dev *dev, int port)
 
 static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 {
-	int port, err;
+	int p, port, err;
 	struct mlx4_vport_state *vp_admin;
 	struct mlx4_vport_oper_state *vp_oper;
 	struct mlx4_slave_state *slave_state  		&priv->mfunc.master.slave_state[slave];
 	struct mlx4_active_ports actv_ports = mlx4_get_active_ports(
 			&priv->dev, slave);
-	int min_port = find_first_bit(actv_ports.ports,
-				      priv->dev.caps.num_ports) + 1;
-	int max_port = min_port - 1 +
-		bitmap_weight(actv_ports.ports, priv->dev.caps.num_ports);
 
-	for (port = min_port; port <= max_port; port++) {
-		if (!test_bit(port - 1, actv_ports.ports))
-			continue;
+	for_each_set_bit(p, actv_ports.ports, priv->dev.caps.num_ports) {
+		port = p + 1;
 		priv->mfunc.master.vf_oper[slave].smi_enabled[port]  			priv->mfunc.master.vf_admin[slave].enable_smi[port];
 		vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
@@ -2063,19 +2058,13 @@ static int mlx4_master_activate_admin_state(struct mlx4_priv *priv, int slave)
 
 static void mlx4_master_deactivate_admin_state(struct mlx4_priv *priv, int slave)
 {
-	int port;
+	int p, port;
 	struct mlx4_vport_oper_state *vp_oper;
 	struct mlx4_active_ports actv_ports = mlx4_get_active_ports(
 			&priv->dev, slave);
-	int min_port = find_first_bit(actv_ports.ports,
-				      priv->dev.caps.num_ports) + 1;
-	int max_port = min_port - 1 +
-		bitmap_weight(actv_ports.ports, priv->dev.caps.num_ports);
 
-
-	for (port = min_port; port <= max_port; port++) {
-		if (!test_bit(port - 1, actv_ports.ports))
-			continue;
+	for_each_set_bit(p, actv_ports.ports, priv->dev.caps.num_ports) {
+		port = p + 1;
 		priv->mfunc.master.vf_oper[slave].smi_enabled[port]  			MLX4_VF_SMI_DISABLED;
 		vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
-- 
2.30.2
