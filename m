From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Sep 2003 00:06:34 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436321832657@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003 01:14:56 +0100
Matthew Wilcox <willy@debian.org> wrote:

> (I can see this descending into get_unaligned_likely() and
> get_aligned_unlikely() which i'd rather avoid ...)

get_unaligned_unlikely() is exactly what just loading the 32-bit value
as if it were aligned is, ie. what we're doing right now.

People who want top performance should not put a networking card into
their machine that can only DMA packets to 32-byte or whatever
boundaries.  That's exactly the limitation NS83820 has and therefore
why it should be avoided like the plague by performance conscious
folks.
