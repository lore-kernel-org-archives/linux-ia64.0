From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Fri, 22 Aug 2003 18:54:38 +0000
Subject: Re: build problems/questions (2.6.0-test3)
Message-Id: <marc-linux-ia64-106157890408708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106151574613417@msgid-missing>
In-Reply-To: <marc-linux-ia64-106151574613417@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Aug 2003 03:25:51 +0100 Matthew Wilcox <willy@debian.org> wrote:

| > 4.  ISA PNP support?
| 
| Definitely no ISA on these boxes.  Shouldn't ISAPNP depend on ISA in Kconfig?

(Adam, this is for ia64 builds.)

My description on #4 was slightly off.  I enabled "Plug and Play support"
but no Protocols under it (neither of ISA PNP or PNP BIOS support),
so only the PNP core is built.  PNP core calls request_dma(),
which is an undefined reference at link time.

So the question becomes, is "PNP support" x86-specific, or at least
not meant for ia64?  Is "PNP support" actually only for ISA and
EISA buses?  If so, it's help text should say so.  As is, it
seems to be very broad.

--
~Randy   [mantra:  Always include kernel version.]  2.6.0-test3
"Everything is relative."
