From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 05 Aug 2009 22:51:42 +0000
Subject: RE: [Patch 2/7] x86: implement crashkernel=auto
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B38E48D7@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
 <20090805112142.6552.18373.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112142.6552.18373.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Amerigo Wang' <amwang@redhat.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, 'Neil Horman' <nhorman@redhat.com>, "'Eric W. Biederman'" <ebiederm@xmission.com>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, 'Ingo Molnar' <mingo@elte.hu>, 'Anton Vorontsov' <avorontsov@ru.mvista.com>

>+#ifdef CONFIG_KEXEC_AUTO_RESERVE
>+	if (strncmp(ck_cmdline, "auto", 4) = 0) {
>+		unsigned long long size;
>+		char tmp[32];
>+
>+		size = arch_default_crash_size(system_ram);
>+		if (size != 0) {
>+			*crash_size = size;
>+			*crash_base = arch_default_crash_base();
>+			size = scnprintf(tmp, sizeof(tmp), "%luM@%luM",
>+					(unsigned long)(*crash_size)>>20,
>+					(unsigned long)(*crash_base)>>20);
>+			/* size can't be <= 4. */
>+			if (likely((size - 4 + strlen(cmdline))
>+					< COMMAND_LINE_SIZE - 1)) {
>+				memmove(ck_cmdline + size, ck_cmdline + 4,
>+					strlen(cmdline) - (ck_cmdline + 4 - cmdline)
>+ 1);
>+				memcpy(ck_cmdline, tmp, size);
>+			}

Here the variable "size" has two different meanings. First it used for crash size. Then its meaning is changed to buffer size in ck_cmdline. And types are different too. The type for crash size is unsigned long long. But scnprintf() return int.

Could you use two variables to represent the two meanings for less confusion?

Thanks.

-Fenghua
