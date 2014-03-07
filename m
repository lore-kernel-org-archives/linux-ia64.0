From: Tejun Heo <tj@kernel.org>
Date: Fri, 07 Mar 2014 12:25:09 +0000
Subject: Re: [PATCH 2/2] kallsyms: handle special absolute symbols
Message-Id: <20140307122509.GA30778@htj.dyndns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394152324-26304-1-git-send-email-keescook@chromium.org>
 <1394152324-26304-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1394152324-26304-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
> index 3c6224728960..4dcda98427cb 100644
> --- a/scripts/kallsyms.c
> +++ b/scripts/kallsyms.c
> @@ -34,6 +34,7 @@ struct sym_entry {
>  	unsigned int len;
>  	unsigned int start_pos;
>  	unsigned char *sym;
> +	int force_absolute;

bool?

Thanks.

-- 
tejun
