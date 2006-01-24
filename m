From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Jan 2006 07:04:21 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124070421.GA32132@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 12:30:42AM -0600, Brent Casavant wrote:
> On Mon, 23 Jan 2006, Grant Grundler wrote:
> > Would an app first need to mmap an uncached address?
> > Or some other obvious "marker" that might warn the kernel?
> 
> I'm not sure an uncached address would be appropriate, as I
> believe there are other non-IO uncached mappings which can
> be performed (whatever the fetchop stuff morphed into, for
> example -- I can't remember what its called now).

OK - just not many user space programs map uncache IO space.

> The only obvious marker I can thing of would be a flag in the
> mm struct set by a device driver when such a mapping occurs.

Device driver? Your original email only talks about user space:
http://marc.theaimsgroup.com/?l=linux-ia64&m3771591308925&w=2

Something that has to go through syscall/mmap and eventually
into IA64 specific code to setup a virtual address.
Or did I miss some later bit about a kernel driver?

> I can't think of any obviously correct state/flag to inspect,
> short of the other suggestion I made tonight.

ok. nevermind then...

grant
