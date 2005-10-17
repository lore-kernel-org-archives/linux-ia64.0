From: Bryan Sutula <Bryan.Sutula@hp.com>
Date: Mon, 17 Oct 2005 16:01:21 +0000
Subject: Re: Handling nested MCA/INIT
Message-Id: <1129564881.19773.18.camel@xw.sutula>
List-Id: <linux-ia64.vger.kernel.org>
References: <6443.1129561424@ocs3.ocs.com.au>
In-Reply-To: <6443.1129561424@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-10-18 at 01:03 +1000, Keith Owens wrote:

> The current MCA/INIT handlers run with psr.mc = 1, so nested events
> cannot be delivered.  This makes it impossible to use the nmi button to
> find out why the MCA/INIT handler is hung.  I am thinking of changing
> mca_asm.S to set psr.mc to 0 to allow nested events.  The handlers
> would detect a nested event, gather minimal diagnostics then reboot.
> Then we may be able to diagnose hung MCA/INIT handlers, right now we
> get no data for this case, which is extremely frustrating.

Your suggestion seems better than a hang.  In a production environment,
it's pretty important to be able to reset the machine reliably.

> The only downside that I can see is if the handler is accessing memory
> with a hard double bit error, we could get nested MCA events.  Since
> the only thing we can do if the MCA handler gets an MCA is to reboot,
> the nested event is not really a problem and allowing nested MCA may
> still give us better diagnostics.

Another issue I see is the case where a second MCA occurs fairly soon
after the first.  With your proposed change, we may lose some of the
information on the first.  (E.g., the handler wasn't hung but just
"doin' it's thing".)  Would there be a way to detect the difference
without complicating the code to the point where it would be unreliable?

-- 
Bryan Sutula <Bryan.Sutula@hp.com>

