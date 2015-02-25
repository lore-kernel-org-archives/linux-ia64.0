From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Wed, 25 Feb 2015 12:59:53 +0000
Subject: Re: [Linaro-acpi] [PATCH v3 3/9] ACPI: clean up checkpatch warnings for various bits of syntax
Message-Id: <54EDC749.8080200@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-4-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-4-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: al.stone@linaro.org, rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, patches@linaro.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org

On 2015年02月25日 08:36, al.stone@linaro.org wrote:
> From: Al Stone<al.stone@linaro.org>
>
> In preparation for later splitting out some of the arch-dependent code from
> osl.c, clean up a bunch of warnings for odd bits of syntax:
>
>     -- remove CVS keyword markers
>     -- remove a space from between a function name and an opening parenthesis
>     -- clean up all but one line > 80 characters (one just looks silly if you
>        make it less than 80)
>     -- add blank lines after declarations in functions
>     -- remove extraneous braces ({})
>
> Signed-off-by: Al Stone<al.stone@linaro.org>

Reviewd-by: Hanjun Guo <hanjun.guo@linaro.org>

Thanks
Hanjun
