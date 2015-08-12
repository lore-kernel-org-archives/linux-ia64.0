From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 12 Aug 2015 22:35:04 +0000
Subject: Re: [Linaro-acpi] [PATCH 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the mac
Message-Id: <CAOZdJXVZomskfpvEjmDUiptW3SndJWvfKyzd9SwJp3dh7h3pig@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438894770-31163-1-git-send-email-al.stone@linaro.org>
	<1438894770-31163-2-git-send-email-al.stone@linaro.org>
In-Reply-To: <1438894770-31163-2-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On Thu, Aug 6, 2015 at 3:59 PM, Al Stone <al.stone@linaro.org> wrote:
> +       while (ms->num_types != 0) {
> +               if (ms->major_version = major &&
> +                   ms->minor_version = minor &&
> +                   ms->madt_version = madt->header.revision)
> +                       break;
> +               ms++;
> +       }
> +       if (!ms) {

Shouldn't this be

  if (!ms->num_types) {

instead?

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
