From: Pavel Machek <pavel@suse.cz>
Date: Tue, 23 Mar 2004 09:56:01 +0000
Subject: Re: add lowpower_idle sysctl
Message-Id: <20040323095600.GE1505@openzaurus.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenneth Chen <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi!

> On ia64, we need runtime control to manage CPU power state in the idle
> loop.  Logically it means a sysctl entry in /proc/sys/kernel.  Even
> though this sysctl entry doesn't exist today, lots of arch already has
> some sort of API to dynamically enable/disable low power idle state.

If you make it "max Cx state to allow", it will be usefull for ACPI people, too...
				Pavel
-- 
64 bytes from 195.113.31.123: icmp_seq( ttlQ timeD8769.1 ms         

