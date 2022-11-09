From: Jonathan Corbet <corbet@lwn.net>
Date: Wed, 09 Nov 2022 20:57:24 +0000
Subject: Re: [PATCH] docs: ia64: Fix a typo ("identify mappings")
Message-Id: <87leojj0vy.fsf@meer.lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221101160609.961950-1-j.neuschaefer@gmx.net>
In-Reply-To: <20221101160609.961950-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linux-doc@vger.kernel.org
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Jonathan Neuschäfer <j.neuschaefer@gmx.net> writes:

> The correct term here, also used in the next line, is "identity
> mappings". "itentify mappings" was probably just a typo.
>
> Signed-off-by: Jonathan Neuschäfer <j.neuschaefer@gmx.net>
> ---
>  Documentation/ia64/aliasing.rst | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/Documentation/ia64/aliasing.rst b/Documentation/ia64/aliasing.rst
> index a08b36aba0159..36a1e1d4842b8 100644
> --- a/Documentation/ia64/aliasing.rst
> +++ b/Documentation/ia64/aliasing.rst
> @@ -61,7 +61,7 @@ Memory Map
>      The efi_memmap table is preserved unmodified because the original
>      boot-time information is required for kexec.
>
> -Kernel Identify Mappings
> +Kernel Identity Mappings
>  ========================

Applied, thanks.

jon
