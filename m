From: Len Brown <lenb@kernel.org>
Date: Wed, 11 May 2016 18:28:34 +0000
Subject: Re: [PATCH v5 1/5] ACPI / processor_idle: introduce ACPI_PROCESSOR_CSTATE
Message-Id: <CAJvTdKmTykoMBw9dCpw0X0ep2qTPSu94-zzUmdrFwUfDeXueqA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462981062-24909-1-git-send-email-sudeep.holla@arm.com>
	<1462981062-24909-2-git-send-email-sudeep.holla@arm.com>
	<CAJvTdKnJPZ9Nfib=CqBczMP4BERqfqAzeSR-+jjFOGZR51oVmg@mail.gmail.com>
In-Reply-To: <CAJvTdKnJPZ9Nfib=CqBczMP4BERqfqAzeSR-+jjFOGZR51oVmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux acpi <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vikas Sajjan <vikas.cha.sajjan@hpe.com>, Sunil <sunil.vl@hpe.com>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, X86 ML <x86@kernel.org>, linux-ia64@vger.kernel.org

What is the functional goal/purpose of adding CONFIG_ACPI_PROCESSOR_CSTATE?

If the answer is that it saves code space on an ARM build, how much
space does it save?

Len Brown, Intel Open Source Technology Center
