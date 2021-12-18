From: Yury Norov <yury.norov@gmail.com>
Date: Sat, 18 Dec 2021 21:19:58 +0000
Subject: [PATCH 02/17] drivers: rename num_*_cpus variables
Message-Id: <20211218212014.1315894-3-yury.norov@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211218212014.1315894-1-yury.norov@gmail.com>
In-Reply-To: <20211218212014.1315894-1-yury.norov@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, Yury Norov <yury.norov@gmail.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>, "Paul E. McKenney" <paulmck@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Alexey Klimov <aklimov@redhat.com>, Amitkumar Karwar <amitkarwar@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Andy Gross <agross@kernel.org>, Andy Lutomirski <luto@kernel.org>, Andy Shevchenko <andy@infradead.org>, Anup Patel <anup.patel@wdc.com>, Ard Biesheuvel <ardb@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, Christoph Lameter <cl@linux.com>, Daniel Vetter <daniel@ffwll.ch>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, David Laight <David.Laight@ACULAB.COM>, Dennis Zhou <dennis@kernel.org>, Emil Renner Berthing <kernel@esmil.dk>, Geert Uytterhoeven <geert@linux-m68k.org>, Geetha sowjanya <gakula@marvell.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guo Ren <guoren@kernel.org>, Hans de Goede <hdegoede@redhat.com>, Heiko Carstens <hca@linux.ibm.com>, Ian Rogers <irogers@google.com>, Ingo Molnar <mingo@redhat.com>, Jakub Kicinski <kuba@kernel.org>, Jason Wessel <jason.wessel@windriver.com>, Jens Axboe <axboe@fb.com>, Jiri Olsa <jolsa@redhat.com>, Joe Perches <joe@perches.com>, Jonathan Cameron <jic23@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Kees Cook <keescook@chromium.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Lee Jones <lee.jones@linaro.org>, Marc Zyngier <maz@kernel.org>, Marcin Wojtas <mw@semihalf.com>, Mark Gross <markgross@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matti Vaittinen <mazziesaccount@gmail.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>, Nicholas Piggin <npiggin@gmail.com>, Palmer Dabbelt <palmer@dabbelt.com>, Peter Zijlstra <peterz@infradead.org>, Petr Mladek <pmladek@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Russell King <linux@armlinux.org.uk>, Saeed Mahameed <saeedm@nvidia.com>, Sagi Grimberg <sagi@grimberg.me>, Sergey Senozhatsky <senozhatsky@chromium.org>, Solomon Peachy <pizza@shaftnet.org>, Stephen Boyd <sboyd@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Subbaraya Sundeep <sbhatta@marvell.com>, Sudeep Holla <sudeep.holla@arm.com>, Sunil Goutham <sgoutham@marvell.com>, Tariq Toukan <tariqt@nvidia.com>, Tejun Heo <tj@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Thomas Gleixner <tglx@linutronix.de>, Ulf Hansson <ulf.hansson@linaro.org>, Vincent Guittot <vincent.guittot@linaro.org>, Vineet Gupta <vgupta@kernel.org>, Viresh Kumar <viresh.kumar@linaro.org>, Vivien Didelot <vivien.didelot@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>, bcm-kernel-feedback-list@broadcom.com, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-perf-users@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

Some drivers declare num_active_cpus and num_present_cpus,
despite that kernel has macros with corresponding names in
linux/cpumask.h, and the drivers include cpumask.h

The following patches switch num_*_cpus() to real functions,
which causes build failures for the drivers.

Signed-off-by: Yury Norov <yury.norov@gmail.com>
---
 drivers/leds/trigger/ledtrig-cpu.c | 6 +++---
 drivers/scsi/storvsc_drv.c         | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/leds/trigger/ledtrig-cpu.c b/drivers/leds/trigger/ledtrig-cpu.c
index 8af4f9bb9cde..767e9749ca41 100644
--- a/drivers/leds/trigger/ledtrig-cpu.c
+++ b/drivers/leds/trigger/ledtrig-cpu.c
@@ -39,7 +39,7 @@ struct led_trigger_cpu {
 static DEFINE_PER_CPU(struct led_trigger_cpu, cpu_trig);
 
 static struct led_trigger *trig_cpu_all;
-static atomic_t num_active_cpus = ATOMIC_INIT(0);
+static atomic_t _active_cpus = ATOMIC_INIT(0);
 
 /**
  * ledtrig_cpu - emit a CPU event as a trigger
@@ -79,8 +79,8 @@ void ledtrig_cpu(enum cpu_led_event ledevt)
 
 		/* Update trigger state */
 		trig->is_active = is_active;
-		atomic_add(is_active ? 1 : -1, &num_active_cpus);
-		active_cpus = atomic_read(&num_active_cpus);
+		atomic_add(is_active ? 1 : -1, &_active_cpus);
+		active_cpus = atomic_read(&_active_cpus);
 		total_cpus = num_present_cpus();
 
 		led_trigger_event(trig->_trig,
diff --git a/drivers/scsi/storvsc_drv.c b/drivers/scsi/storvsc_drv.c
index 20595c0ba0ae..705dd4ebde98 100644
--- a/drivers/scsi/storvsc_drv.c
+++ b/drivers/scsi/storvsc_drv.c
@@ -1950,7 +1950,7 @@ static int storvsc_probe(struct hv_device *device,
 {
 	int ret;
 	int num_cpus = num_online_cpus();
-	int num_present_cpus = num_present_cpus();
+	int present_cpus = num_present_cpus();
 	struct Scsi_Host *host;
 	struct hv_host_device *host_dev;
 	bool dev_is_ide = ((dev_id->driver_data = IDE_GUID) ? true : false);
@@ -2060,7 +2060,7 @@ static int storvsc_probe(struct hv_device *device,
 	 * Set the number of HW queues we are supporting.
 	 */
 	if (!dev_is_ide) {
-		if (storvsc_max_hw_queues > num_present_cpus) {
+		if (storvsc_max_hw_queues > present_cpus) {
 			storvsc_max_hw_queues = 0;
 			storvsc_log(device, STORVSC_LOGGING_WARN,
 				"Resetting invalid storvsc_max_hw_queues value to default.\n");
@@ -2068,7 +2068,7 @@ static int storvsc_probe(struct hv_device *device,
 		if (storvsc_max_hw_queues)
 			host->nr_hw_queues = storvsc_max_hw_queues;
 		else
-			host->nr_hw_queues = num_present_cpus;
+			host->nr_hw_queues = present_cpus;
 	}
 
 	/*
-- 
2.30.2
