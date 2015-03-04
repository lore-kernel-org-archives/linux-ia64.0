From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Wed, 04 Mar 2015 22:41:21 +0000
Subject: Re: [PATCH v3 1/9] ACPI: fix all errors reported by cleanpatch.pl in osl.c
Message-Id: <1528624.HcuCny6IaW@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1424824585-6405-2-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-2-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: al.stone@linaro.org
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Tuesday, February 24, 2015 05:36:17 PM al.stone@linaro.org wrote:
> From: Al Stone <al.stone@linaro.org>
> 
> In preparation for later splitting out some of the arch-dependent code from
> osl.c, clean up the errors reported by checkpatch.pl.  They fell into these
> classes:
> 
>    -- remove the FSF address from the GPL notice
>    -- "foo * bar" should be "foo *bar" (and the ** variation of same)
>    -- a return is not a function, so parentheses are not required.
> 
> Signed-off-by: Al Stone <al.stone@linaro.org>

checkpatch.pl is irrelevant here.  You're trying to make the coding style be
more consistent with the coding style of the rest of the kernel.

The warnings from checkpatch.pl are meaningless for the existing code, so
it should not be used to justify changes in that code.

Of course, the same applies to patches [2-4/9].


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
