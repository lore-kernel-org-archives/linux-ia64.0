From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 16 Dec 2004 07:59:34 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <41C14066.2090203@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Thu, 16 Dec 2004, Nick Piggin wrote:
> 
>>Would it be possible to just *allocate* the page, zero it, then
>>free it, and have it get put onto the zero page list from there?
>>If you conceptually think of a page being zeroed as being in use,
>>then it would be natural to allocate it...?
> 
> 
> I tried that. This increases the overhead significantly. Also if you put
> back a zeroed page and its going to be merged with its neighbor (likely
> not zeroed) then the zero bit has to be dropped. Its then getting a bit
> difficult to get zeroed pages into the buddy allocator.
> 
> One could set the zero bit on each individual page but then that increases
> again overhead of managing them and checking them.
> 

Hmm, I was thinking 'free' the zeroed page stright onto the pcp zero list.
This probably doesn't work well, though, if you want to zero a large
proportion of system memory...

