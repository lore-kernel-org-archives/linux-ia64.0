From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Dec 2002 01:20:34 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Dec 2002 17:18:07 -0800, Richard Henderson <rth@twiddle.net> said:

  Rich> On Thu, Dec 19, 2002 at 05:07:54PM -0800, David Mosberger
  Rich> wrote:
  >> They're in a section called .plt.

  Rich> Oh, you're talking about modules.  I was still talking about
  Rich> ld.so.

Yep.  I agree it's a different issue in general, but for kernel
modules, it should be fine (and worthwhile).

	--david

