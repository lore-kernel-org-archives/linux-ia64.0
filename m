From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 26 Aug 2015 15:38:42 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <CAOZdJXXCnb7ChYqh-QYptTQBmfESDPaauThHyu8Dav6Qs_+4Bw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
	<1440022048-6285-2-git-send-email-al.stone@linaro.org>
In-Reply-To: <1440022048-6285-2-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On Wed, Aug 19, 2015 at 5:07 PM, Al Stone <al.stone@linaro.org> wrote:
> +                               pr_err("Variable length MADT subtable %d is wrong size: %d\n",
> +                                      entry->type, entry->length);
> +                               return 1;
> +                       }
> +               }
> +       } else {
> +               if (entry->length != len) {
> +                       pr_err("MADT subtable %d is wrong size: %d\n",
> +                              len, entry->type);

Can we make these a little more descriptive?

pr_err("Variable length MADT subtable type %d is wrong size: %d,
should be %d\n",
      entry->type, entry->length, len);

pr_err("MADT subtable type %d is wrong size: %d, should be %d\n",
      entry->type, entry->length, len);




-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
