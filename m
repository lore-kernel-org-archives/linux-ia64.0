From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Dec 2002 01:07:54 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Dec 2002 16:56:51 -0800, Richard Henderson <rth@twiddle.net> said:

  Richard> On Thu, Dec 19, 2002 at 03:15:49PM -0800, David Mosberger
  Richard> wrote:
  Rich> No it isn't.  Find me the address of the stub.
  >>  After you're done applying relocations, what stops you from
  >> going through all PLTs and patching them to use "brl"?

  Richard> You're not listening.  WHERE ARE THEY?  You don't have
  Richard> their address.  You only have the address of the descriptor
  Richard> that they use.

They're in a section called .plt.  When you load the module, you have
access to the section table, so I don't see the problem (yes, you need
to do some calculations on the section-size to figure out where the
PLTs to patch start, but that should be it).

	--david

