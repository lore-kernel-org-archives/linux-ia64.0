From: n0ano@indstorage.com
Date: Mon, 22 Apr 2002 15:40:41 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905491@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

True, but with both of these solutions all of the `.o's will still
have the debug info and will therefore be very large.  I think I'll
keep removing the `-g' flag.

On Mon, Apr 22, 2002 at 08:34:39AM -0700, David Mosberger wrote:
> >>>>> On Mon, 22 Apr 2002 16:57:20 +0200, Andreas Schwab <schwab@suse.de> said:
> 
>...
>
>   Andreas> Or just use "strip -g".
> 
> Or "make compressed", which will give you vmlinux (with debug info),
> and vmlinux.gz (without debug info).
> 
> 	--david

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

