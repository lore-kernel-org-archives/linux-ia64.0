From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 25 Aug 2003 09:30:30 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106180387608872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

Christoph> Anyway, we should test explicitly for configurations
Christoph> supported by floppy.c.  So far this would be:

Christoph> CONFIG_ISA CONFIG_M68K CONFIG_SPARC

CONFIG_SPARC64 I believe. No idea about MIPS configurations.

Jes


