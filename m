From: Jonathan Corbet <corbet@lwn.net>
Date: Mon, 13 Jul 2020 14:34:08 +0000
Subject: Re: [PATCH] ia64: Replace HTTP links with HTTPS ones
Message-Id: <20200713083408.38154746@lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200713141036.34841-1-grandmaster@al2klimov.de>
In-Reply-To: <20200713141036.34841-1-grandmaster@al2klimov.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Alexander A. Klimov" <grandmaster@al2klimov.de>
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 13 Jul 2020 16:10:36 +0200
"Alexander A. Klimov" <grandmaster@al2klimov.de> wrote:

> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index 1fa2fe2ef053..f21f121a8f42 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -223,7 +223,7 @@ config SMP
>  	  will run faster if you say N here.
>  
>  	  See also the SMP-HOWTO available at
> -	  <http://www.tldp.org/docs.html#howto>.
> +	  <https://www.tldp.org/docs.html#howto>.

No such HOWTO exists; far better to just delete this sentence entirely.

jon
