From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 18 Nov 2003 17:10:32 +0000
Subject: Re: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106917559326802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 18, 2003 at 07:11:20PM +0900, Hidetoshi Seto wrote:
> Assuming that Linux uses privilege level to determine action on MCA between
> kill the thread and down the system, if driver encounters MCA caused by I/O
> read, Linux should be down since privilege level of driver is kernel, not user.
> I want to convey the error to the offending driver, and want to enable the
> driver to retry failed read.

This would not only be useful for the occasional device failure, but
also for accessing memory spaces which by definition may or may not
respond to PIO requets, like legacy I/O bus and memory regions.  Upon
entering readb_check(), you could set a global telling the MCA handler
to potentially expect a failure from the address or range that was
passed in.  This would allow the MCA handler describe in simple terms
what went wrong in case of failure and/or take appropriate action.

> So, I think about a readb_check function that has checking ability
> enable it return error value if MCA occur on read.  Drivers could use
> readb_check instead of usual readb, and could diagnosis whether a
> retry be required or not, by the return value of readb_check.

Since this proposal would affect the driver API, it should probably be
discussed on linux-kernel@vger.kernel.org.  It may be beneficial to
other systems that hard fail under similar circumstances.

Jesse
