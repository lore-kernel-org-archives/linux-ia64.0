From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 23 Feb 2016 23:42:06 +0000
Subject: Re: [UPDATE] [PATCH v3 2/5] ACPI / sleep: move acpi_processor_sleep to sleep.c
Message-Id: <1701970.yNzfYrMntI@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-3-git-send-email-sudeep.holla@arm.com> <1455710603-14994-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1455710603-14994-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

On Wednesday, February 17, 2016 12:03:23 PM Sudeep Holla wrote:
> acpi_processor_sleep is neither related nor used by CPUIdle framework.
> It's used in system suspend/resume path as a syscore operation. It makes
> more sense to move it to acpi/sleep.c where all the S-state transition
> (a.k.a. Linux system suspend/hiberate) related code are present.
> 
> Also make it depend on CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT so that
> it's not compiled on architecture like ARM64 where S-states are not
> yet defined in ACPI.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>

Queued up for 4.6, thanks!

Rafael

