From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 17 Oct 2003 13:32:19 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106639760009691@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <willy@debian.org> writes:

Matthew> On Thu, Oct 16, 2003 at 12:29:58PM -0700, Grant Grundler
Matthew> wrote:
>> This doesn't feel like a great solution.  Willy suggested the right
>> fix might be to not require all arches to provide asm/kmap_types.h.
>> I'll let the folks who know WTH kmap_types.h is really for debate
>> and submit this with the hope of getting the ia64-linux to build
>> with CONFIG_CRYPTO.

Matthew> Cloning kmap_types from i386 is a pretty bad idea since that
Matthew> architecture actually supports highmem.  Better to clone from
Matthew> an arch which has no support for highmem such as ARM.

I'd argue we should fix the crypto code instead, it doesn't seem
reasonable for them to require kmap types to be defined on archs that
don't have highmem.

Cheers,
Jes
