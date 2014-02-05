From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Wed, 05 Feb 2014 22:17:33 +0000
Subject: [PATCH 05/51] ia64, palinfo: Fix CPU hotplug callback registration
Message-Id: <20140205220532.19080.79983.stgit@srivatsabhat.in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org
Cc: mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>

Subsystems that want to register CPU hotplug callbacks, as well as perform
initialization for the CPUs that are already online, often do it as shown
below:

	get_online_cpus();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	register_cpu_notifier(&foobar_cpu_notifier);

	put_online_cpus();

This is wrong, since it is prone to ABBA deadlocks involving the
cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
with CPU hotplug operations).

Instead, the correct and race-free way of performing the callback
registration is:

	cpu_maps_update_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_maps_update_done();


Fix the palinfo code in ia64 by using this latter form of callback
registration.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/palinfo.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index ab33328..cfaa06f 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -996,13 +996,17 @@ palinfo_init(void)
 	if (!palinfo_dir)
 		return -ENOMEM;
 
+	cpu_maps_update_begin();
+
 	/* Create palinfo dirs in /proc for all online cpus */
 	for_each_online_cpu(i) {
 		create_palinfo_proc_entries(i);
 	}
 
 	/* Register for future delivery via notify registration */
-	register_hotcpu_notifier(&palinfo_cpu_notifier);
+	__register_hotcpu_notifier(&palinfo_cpu_notifier);
+
+	cpu_maps_update_done();
 
 	return 0;
 }

