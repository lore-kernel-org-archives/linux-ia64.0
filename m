From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 06 Oct 2003 18:57:06 +0000
Subject: Re: [PATCH] more dead headers
Message-Id: <marc-linux-ia64-106546697024143@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106467172926098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106467172926098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@lst.de> writes:

Christoph> On Sun, Oct 05, 2003 at 12:41:03PM -0400, Jes Sorensen
Christoph> wrote:
>> fetchop.h and ioc4.h are for GPL'ed drivers that have already been
>> published for 2.4 - they just need to be ported to 2.6. We can take
>> them out now and stick them back in later if you prefer but doing
>> so seems silly to me.

Christoph> It's still the wrong place for them.  And the ioc4 driver
Christoph> including most of the header is so utter junk that it needs
Christoph> a complete rewrite anyway.

I don't have a problem moving fetchop.h, it's very hardware specific
though. ioc4 will have to migrate to relying a lot more on existing
infrastructure.

Jes
