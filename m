From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 10 Nov 2003 08:26:50 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106845283422586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Sylvain" = Sylvain Jeaugey <sylvain.jeaugey@bull.net> writes:

Sylvain> These lines show you the numa topology of your machine (in
Sylvain> our case, we have 2 CPUS per domain, and a memory area).
Sylvain> This is quite a big piece of information about hardware. Even
Sylvain> if it is quite long, I think it should be part of the ACPI
Sylvain> information.

Hi Sylvian,

This information is much better exposed through sysfs (/sys) and Andi
Kleen's libnuma, which will also make it visible at runtime to
applications.

Cheers,
Jes
