From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Dec 2003 17:33:47 +0000
Subject: Re: ia64 atomic_dec_and_lock() patch
Message-Id: <marc-linux-ia64-107107785321633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107107082810707@msgid-missing>
In-Reply-To: <marc-linux-ia64-107107082810707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jermone,

>>>>> On Wed, 10 Dec 2003 16:37:22 +0100 (NFT), jerome.marchand@ext.bull.net said:

  Jerome> I have run a benchmark which load heavily the vfs on a 16
  Jerome> Itanium computer. When using lockmeter, I have noticed that
  Jerome> dcache_lock induce a significant contention when called from
  Jerome> dput. I observed a case in which 80% of CPUs time was used
  Jerome> in spin-wait!  The ia64 kernel waste all this time because
  Jerome> there is no ia64-specific implementation of
  Jerome> atomic_dec_and_lock() and the kernel use the generic
  Jerome> function instead.  I wrote the ia64 atomic_dec_and_lock
  Jerome> function and since dcache_lock never use more than 0.01% of
  Jerome> CPUs time and I have encountered no problem. The patch is
  Jerome> here.  Does someone know why this function was not
  Jerome> implemented before whereas it is implemented for ia32, ppc,
  Jerome> ppc64, sparc64 and alpha processors ?

Because nobody so far has demonstrated a need for it or hasn't gotten
around to it?

Could you try replacing the inline-asm with cmpxchg() function?  That
way, you won't break compilation with Intel's compiler.

	--david
