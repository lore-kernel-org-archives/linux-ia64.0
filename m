From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 01 Apr 2003 02:06:37 +0000
Subject: Re: [Linux-ia64] Another stupid logging question...
Message-Id: <marc-linux-ia64-105590723705372@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705370@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705370@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <willy@debian.org> writes:

Matthew> On Tue, Apr 01, 2003 at 10:09:02AM +1000, Peter Chubb wrote:
>> Every time I boot my ZX2000, (which as it's a kernel development
>> system is often) I get a little message that says the BMC event log
>> is full.  I can read the log --- it's not very interesting --- but
>> how do I clear it (and the forward progress log, too)?

Matthew> You need to use IPMI to do it.  I forget which commands do
Matthew> that..

That's what I was afraid of...  The CLI interface to IPMI is not
exactly user-friendly.  And because it's not easy to see what one is
doing (magic numebrs everywhere!), it's possible to screw up badly.

I think that this means I do
cli> ipmi 0A 47 0 0 43 4C 52 AA

is that right ?  I *think* this is the code to clear the system event
log; whether that also clears the BMC event log and the forward
progress log I don't know.   The latter two logs are not mentioned in
the IPMI 1.5 spec.

The syntax is:
    ipmi netfnlun cmd data

(BMC cli help)

In this case, the netfn is `storage' (appendix G) which translates to
0x0A (table 5.1 of the IPMI 1.5 spec), and the LUN is zero (low two
bits of netfnlun).  The CMD is `CLR SEL' (0x47 appendix G of IPMI
spec) and the data is 0 0 43 4C 52 AA (section 25.9)

Peter C

