From: William Lee Irwin III <wli@holomorphy.com>
Date: Sun, 19 Oct 2003 19:01:21 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106659031313301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Oct 19, 2003 at 05:25:37AM -0600, Eric W. Biederman wrote:
> We do have all of the information we need in struct page to see if a
> page address is valid, so checking that is reasonable.  I suspect it
> will require some interesting variant of pfn_to_page to handle of the
> weird sparse memory locations properly.

It would be best to check the pfn before attempting to convert it to a
struct page. The struct page * returned by arch code will be garbage in
most instances, as none of the routines actually check validity
internally. pfn_valid() is even bogus on most of them, so you'll have
to walk pgdats by hand for this. The pfn_valid() checks work most of the
time on PC's, but the first time someone runs X on a box with discontig
and a bogus pfn_valid() they'll get fireworks (and in fact, it's already
happened, but wasn't posted to lkml).


-- wli
