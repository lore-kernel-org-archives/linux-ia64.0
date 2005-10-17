From: Keith Owens <kaos@sgi.com>
Date: Mon, 17 Oct 2005 15:03:44 +0000
Subject: Handling nested MCA/INIT
Message-Id: <6443.1129561424@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How should we handle nested MCA/INIT events?  There is only one PAL
minstate area per cpu so any nested MCA/INIT will overwrite the current
data, making it impossible to recover.  The best we can do with a
nested event is get some information on why the handlers died then
reboot.

The current MCA/INIT handlers run with psr.mc = 1, so nested events
cannot be delivered.  This makes it impossible to use the nmi button to
find out why the MCA/INIT handler is hung.  I am thinking of changing
mca_asm.S to set psr.mc to 0 to allow nested events.  The handlers
would detect a nested event, gather minimal diagnostics then reboot.
Then we may be able to diagnose hung MCA/INIT handlers, right now we
get no data for this case, which is extremely frustrating.

The only downside that I can see is if the handler is accessing memory
with a hard double bit error, we could get nested MCA events.  Since
the only thing we can do if the MCA handler gets an MCA is to reboot,
the nested event is not really a problem and allowing nested MCA may
still give us better diagnostics.

