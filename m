From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 18 Oct 2003 00:15:11 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106643594920448@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 04:55:43PM -0700, Andrew Morton wrote:
> This code was conceived before my time and I don't recall seeing much
> discussion, so this is all guesswork..
> I'd say that the high_memory test _is_ superfluous and that if anyone
> cared, we would remove it and establish a temporary pte against the address if
> it was outside the direct-mapped area.  But nobody cares enough to have
> done anything about it.

I've heard crash dump people mention it and am trying to convince them
to post their fix(es) here. =)


-- wli
