From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 00:11:10 +0000
Subject: Re: [RFC/PATCH] discontig update for linux-ia64-2.5 bk tree
Message-Id: <marc-linux-ia64-105598154013945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105595347015732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105595347015732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I missed this on first reading:

 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
 			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
 			cpu_data += PERCPU_PAGE_SIZE;
 		}
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			cpu_data = __per_cpu_offset[cpu] + __per_cpu_start;
+			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
+		}

What's the point of this?

The patch still removes CONFIG_VIRTUAL_MEM_MAP.

Also, please note that I don't want to add any ia64 patches that
create additional dependencies on core code (I'm trying to sync things
such that ia64 builds out of the box).  So before submitting
ia64-specific changes, please make sure the core-code is ready for it.

	--david
