From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Oct 2003 12:13:08 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106639299505189@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 09:20:33AM +1000, Keith Owens wrote:
> That is an error in crypto/internal.h.  Nothing should include
> asm/kmap_types.h directly, they should include linux/highmem.h and let
> that decide if the arch needs kmap or not.

The would be the logical conclusion, but the crypto maintainers
decided this is a feature and not a bug..

