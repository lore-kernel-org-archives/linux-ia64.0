From: Jonathan Corbet <corbet@lwn.net>
Date: Thu, 23 Jul 2020 20:47:25 +0000
Subject: Re: [PATCH v2] ia64: Replace HTTP links with HTTPS ones
Message-Id: <20200723144725.17e369e0@lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200713083408.38154746@lwn.net>
        <20200713215506.44327-1-grandmaster@al2klimov.de>
In-Reply-To: <20200713215506.44327-1-grandmaster@al2klimov.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Alexander A. Klimov" <grandmaster@al2klimov.de>
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 13 Jul 2020 23:55:06 +0200
"Alexander A. Klimov" <grandmaster@al2klimov.de> wrote:

>  Documentation/ia64/xen.rst | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/ia64/xen.rst b/Documentation/ia64/xen.rst
> index 831339c74441..9da6abb02a2c 100644
> --- a/Documentation/ia64/xen.rst
> +++ b/Documentation/ia64/xen.rst
> @@ -28,7 +28,7 @@ Getting and Building Xen and Dom0
>  
>  	# hg clone http://xenbits.xensource.com/ext/ia64/xen-unstable.hg
>  	# cd xen-unstable.hg
> -	# hg clone http://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
> +	# hg clone https://xenbits.xensource.com/ext/ia64/linux-2.6.18-xen.hg
>  
>   2. # make world

So ... this is a sequence of operations that clearly cannot work at all
since the repo link you didn't change is broken.  And if it were to
somehow work, we'd get ... a 2.6.18 version of ia64 xen?  I think that the
proper solution here is to simply delete this document...

jon
