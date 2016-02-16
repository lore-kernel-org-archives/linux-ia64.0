From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 16 Feb 2016 20:10:10 +0000
Subject: Re: [PATCH v3 1/5] ACPI / processor : add support for ACPI0010 processor container
Message-Id: <1911447.Jqz0QvxEGY@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com> <1449065446-26115-2-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1449065446-26115-2-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

On Wednesday, December 02, 2015 02:10:42 PM Sudeep Holla wrote:
> ACPI 6.0 adds support for optional processor container device which may
> contain child objects that are either processor devices or other processor
> containers. This allows representing hierarchical processor topologies.
> 
> It is declared using the _HID of ACPI0010. It is an abstract container
> used to represent CPU topology and should not be used to hotplug
> purposes.
> 
> This patch enables the support for these ACPI processor containers and
> ensures the generic container/module devices are not created for them.

I wouldn't say that it "enables the support".  What it actually does is
to prevent platform devices from being created for processor container
objects.

I can apply it right away with this changelog modification, though.

Thanks,
Rafael

