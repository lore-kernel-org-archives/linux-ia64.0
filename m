From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 16 Feb 2016 20:15:32 +0000
Subject: Re: [PATCH v3 3/5] ACPI / processor_idle: replace PREFIX with pr_fmt
Message-Id: <3649354.2b9ioZHemq@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com> <1449065446-26115-4-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1449065446-26115-4-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

On Wednesday, December 02, 2015 02:10:44 PM Sudeep Holla wrote:
> Like few of the other ACPI modules, replace PREFIX with pr_fmt and
> change all the printk call sites to use pr_* companion functions
> in processor_idle.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>

I've queued up this one for 4.6.

Thanks,
Rafael

