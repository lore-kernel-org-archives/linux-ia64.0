From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 16 Dec 2004 16:27:18 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412160826180.8803@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Dec 2004, Nick Piggin wrote:

> > One could set the zero bit on each individual page but then that increases
> > again overhead of managing them and checking them.
> Hmm, I was thinking 'free' the zeroed page stright onto the pcp zero list.
> This probably doesn't work well, though, if you want to zero a large
> proportion of system memory...

Thats an interesting idea for order 0 pages that would avoid the merge in
issue with the buddy allocator.

