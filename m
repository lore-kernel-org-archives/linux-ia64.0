From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Dec 2002 23:15:49 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 23:20:26 -0800, Richard Henderson <rth@twiddle.net> said:

  Rich> On Mon, Dec 16, 2002 at 07:50:53PM -0800, David Mosberger
  Rich> wrote:
  >> I assume you do early binding of the PLTs for kernel modules,
  >> right?

  Rich> Yes.

  >> If so, patching the PLT code stub is trivial.

  Rich> No it isn't.  Find me the address of the stub.

After you're done applying relocations, what stops you from going
through all PLTs and patching them to use "brl"?

	--david

