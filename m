From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 08 Dec 2003 22:09:46 +0000
Subject: Re: memory fence.
Message-Id: <marc-linux-ia64-107092173127002@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107092124126396@msgid-missing>
In-Reply-To: <marc-linux-ia64-107092124126396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For the kernel, it's usually just mb(), but there are a few different
kinds of memory fences.

Jesse

On Mon, Dec 08, 2003 at 02:01:54PM -0800, Umut Aymakoglu wrote:
> 
> 
> 
> 
> Hi -
>  Does anybody know the equivalance of  _Asm_mf() (HP ia64) on Linux ia64?
> 
> thanks,
> Umut
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
