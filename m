From: Christoph Hellwig <hch@lst.de>
Date: Mon, 06 Oct 2003 12:19:33 +0000
Subject: Re: [PATCH] kill sn_ksyms.c
Message-Id: <marc-linux-ia64-106544279227570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451999732538@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451999732538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Oct 05, 2003 at 12:33:00PM -0400, Jes Sorensen wrote:
> >>>>> "Christoph" = Christoph Hellwig <hch@lst.de> writes:
> 
> Christoph> None of the exported symbols is referenced by a module,
> Christoph> even more the file doesn't compile shen
> Christoph> CONFIG_IA64_SGI_SN_DEBUG is set.
> 
> There are some device drivers coming that will depend on some of these
> symbols so I'd prefer to keep this file in place, at least for
> now. And yes, said drivers are GPL'ed.

Most of that stuff isn't even used by ioc4 or fetchop and *ksyms.c are
on their way out.  Add new exports to the files defining the symbols
when a new drivers needs them.

