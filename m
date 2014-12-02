From: Kevin Hilman <khilman@kernel.org>
Date: Tue, 02 Dec 2014 01:10:32 +0000
Subject: Re: [PATCH] PM / Kconfig: Do not select PM directly from Kconfig files
Message-Id: <7h388y501j.fsf@deeprootsystems.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4088467.A4Xd3YfMSv@vostro.rjw.lan>
In-Reply-To: <4088467.A4Xd3YfMSv@vostro.rjw.lan> (Rafael J. Wysocki's message
	of "Sat, 29 Nov 2014 02:03:48 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, linux-sh@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

"Rafael J. Wysocki" <rjw@rjwysocki.net> writes:

> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>
> It is not valid to select CONFIG_PM directly without selecting
> CONFIG_PM_SLEEP or CONFIG_PM_RUNTIME too, because that breaks
> dependencies (ia64 does that) and it is not necessary to select
> CONFIG_PM directly if CONFIG_PM_SLEEP or CONFIG_PM_RUNTIME is
> set, because it will be set automatically then (sh does that).
>
> Fix those mistakes.
>
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Reviewed-by: Kevin Hilman <khilman@linaro.org>
