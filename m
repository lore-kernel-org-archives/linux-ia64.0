From: Jes Sorensen <jes@wildopensource.com>
Date: Sun, 05 Oct 2003 16:33:00 +0000
Subject: Re: [PATCH] kill sn_ksyms.c
Message-Id: <marc-linux-ia64-106537167010646@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451999732538@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451999732538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@lst.de> writes:

Christoph> None of the exported symbols is referenced by a module,
Christoph> even more the file doesn't compile shen
Christoph> CONFIG_IA64_SGI_SN_DEBUG is set.

There are some device drivers coming that will depend on some of these
symbols so I'd prefer to keep this file in place, at least for
now. And yes, said drivers are GPL'ed.

Jes
