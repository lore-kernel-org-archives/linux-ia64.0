From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 17 Oct 2003 13:33:27 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106639778909907@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Hellwig <hch@infradead.org> writes:

Christoph> On Fri, Oct 17, 2003 at 09:20:33AM +1000, Keith Owens
Christoph> wrote:
>> That is an error in crypto/internal.h.  Nothing should include
>> asm/kmap_types.h directly, they should include linux/highmem.h and
>> let that decide if the arch needs kmap or not.

Christoph> The would be the logical conclusion, but the crypto
Christoph> maintainers decided this is a feature and not a bug..

Well then we send Linus a big-fix, clearly this is a bug, if the
crypto maintainer doesn't want to fix it, we'll have to fix it for
him/her.

Jes
