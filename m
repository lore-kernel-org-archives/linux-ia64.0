From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 01 Dec 2003 19:25:20 +0000
Subject: Re: Missing code in bootmem.c for discontigmem
Message-Id: <marc-linux-ia64-107030679217883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106994770902664@msgid-missing>
In-Reply-To: <marc-linux-ia64-106994770902664@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 01, 2003 at 09:22:12AM -0800, Jesse Barnes wrote:
> Yeah, sorry about that, I knew there would be a problem.  We need to fix
> the ia64 discontig code to init the boot memory in the correct order
> instead since the below change breaks other discontig platforms.

It looks like we should break out the second half of
discontig.c:find_pernode_space() into a second function that inits the
bootmaps in reverse order.  As an added bonus, we could check to make
sure that all of the pernode spaces actually got allocated and print a
warning and/or disable the node if not.  That would make debugging weird
init time failures a bit easier (I think Alex ran into a problem that
would have been quickly solved if we had such checks).  Wanna take a
stab at it?

Thanks,
Jesse
