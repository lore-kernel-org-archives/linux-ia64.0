From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 21:22:40 +0000
Subject: [Linux-ia64] CPU hotplug boot change for IA64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------_3D4AF04BED740199A208_MULTIPART_MIXED_"
Message-Id: <marc-linux-ia64-105590701905891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--------_3D4AF04BED740199A208_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi David, Rusty,

I attached a CPU hotplug boot change patch for IA-64
against 2.5.29 + David's IA64 patch. Please include this in
the next release.

I've just tested it on a 2way Bigsur but it should work on
the other systems.

In this patch, I added initial value of cpu_online_map as following,

 /* Bitmask of currently online CPUs */
-volatile unsigned long cpu_online_map;
+volatile unsigned long cpu_online_map = 1;
 unsigned long phys_cpu_present_map;

Bit for CPU#0 on cpu_online_map was set at smp_boot_cpus() before.
But on the 2.5.29, place of calling smp_boot_cpus() is changed to
later timing and this seems to make a chance that smp_call_function()
is called before setting cpu_online_map, (I guess.)
In that case, smp_call_function won't return because num_online_cpus()
returns 0 and the system will hang.

I have an experience of this problem only on a large system
like Tiger, but it may occur on another system.

Rusty, I guess this modification should be needed for i386, too.

I'd appreciate any comment.

Thanks,
Kimi

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>

--------_3D4AF04BED740199A208_MULTIPART_MIXED_
Content-Type: application/octet-stream; name="hotplug-boot-change-ia64.patch.gz"
Content-Disposition: attachment;
 filename="hotplug-boot-change-ia64.patch.gz"
Content-Transfer-Encoding: base64

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

--------_3D4AF04BED740199A208_MULTIPART_MIXED_--


