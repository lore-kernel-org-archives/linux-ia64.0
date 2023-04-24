From: Nathan Chancellor <nathan@kernel.org>
Date: Mon, 24 Apr 2023 17:11:30 +0000
Subject: Re: [PATCH] scripts: Remove ICC-related dead code
Message-Id: <20230424171130.GA2606535@dev-arch.thelio-3990X>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221016182349.49308-1-masahiroy@kernel.org>
 <20230424162110.11082-1-lrh2000@pku.edu.cn>
In-Reply-To: <20230424162110.11082-1-lrh2000@pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ruihan Li <lrh2000@pku.edu.cn>
Cc: torvalds@linux-foundation.org, masahiroy@kernel.org, arnd@arndb.de, bp@alien8.de, dave.hansen@linux.intel.com, devel@acpica.org, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev, mingo@redhat.com, ndesaulniers@google.com, ojeda@kernel.org, rafael@kernel.org, robert.moore@intel.com, terrelln@fb.com, tglx@linutronix.de, trix@redhat.com, x86@kernel.org

On Tue, Apr 25, 2023 at 12:21:10AM +0800, Ruihan Li wrote:
> Intel compiler support has already been completely removed in commit
> 95207db8166a ("Remove Intel compiler support"). However, it appears that
> there is still some ICC-related code in scripts/cc-version.sh. There is
> no harm in leaving the code as it is, but removing the dead code makes
> the codebase a bit cleaner.
> 
> Hopefully all ICC-related stuff in the build scripts will be removed
> after this commit, given the grep output as below:
> 
> 	(linux/scripts) $ grep -i -w -R 'icc'
> 	cc-version.sh:ICC)
> 	cc-version.sh:	min_version=$($min_tool_version icc)
> 	dtc/include-prefixes/arm64/qcom/sm6350.dtsi:#include <dt-bindings/interconnect/qcom,icc.h>
> 
> Fixes: 95207db8166a ("Remove Intel compiler support")
> Signed-off-by: Ruihan Li <lrh2000@pku.edu.cn>

Thanks for the patch. I am not sure this patch really needs a fixes tag,
as I do not really think dead code is a bug (and the commit message even
mentions this), but who cares I guess? :) cleanups are always nice.

Reviewed-by: Nathan Chancellor <nathan@kernel.org>

> ---
>  scripts/cc-version.sh | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/scripts/cc-version.sh b/scripts/cc-version.sh
> index 0573c92e8..a7e28b6a5 100755
> --- a/scripts/cc-version.sh
> +++ b/scripts/cc-version.sh
> @@ -45,10 +45,6 @@ Clang)
>  	version=$2.$3.$4
>  	min_version=$($min_tool_version llvm)
>  	;;
> -ICC)
> -	version=$(($2 / 100)).$(($2 % 100)).$3
> -	min_version=$($min_tool_version icc)
> -	;;
>  *)
>  	echo "$orig_args: unknown C compiler" >&2
>  	exit 1
> -- 
> 2.40.0
> 
