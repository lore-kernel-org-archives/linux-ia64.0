From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 23 Feb 2005 08:24:28 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <1109147069.6290.45.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	 <1109109833.6024.109.camel@laptopd505.fenrus.org>
	 <yq04qg4i5wu.fsf@jaguar.mkp.net>
	 <1109112142.6024.119.camel@laptopd505.fenrus.org>
	 <yq0wtszeluv.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wtszeluv.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>  However what happens if someone wants to share say some
> texture ram between the kernel and a video card and that has to be
> mapped uncached? Though up example here though.

also that's surely supposed to be controlled by some kernel driver,
which in turn can and should export it's own mmap instead with all the
proper attributes...


