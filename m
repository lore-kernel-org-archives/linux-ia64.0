From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Wed, 25 Feb 2015 12:47:53 +0000
Subject: Re: [PATCH v3 1/9] ACPI: fix all errors reported by cleanpatch.pl in osl.c
Message-Id: <54EDC479.4000603@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-2-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-2-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: al.stone@linaro.org, rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On 2015年02月25日 08:36, al.stone@linaro.org wrote:
> From: Al Stone <al.stone@linaro.org>
>
> In preparation for later splitting out some of the arch-dependent code from
> osl.c, clean up the errors reported by checkpatch.pl.  They fell into these
> classes:
>
>     -- remove the FSF address from the GPL notice
>     -- "foo * bar" should be "foo *bar" (and the ** variation of same)
>     -- a return is not a function, so parentheses are not required.
>
> Signed-off-by: Al Stone <al.stone@linaro.org>

Reviewd-by: Hanjun Guo <hanjun.guo@linaro.org>

Thanks
Hanjun
