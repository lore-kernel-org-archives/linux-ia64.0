From: Jim Wilson <wilson@specifixinc.com>
Date: Mon, 20 Oct 2003 22:24:12 +0000
Subject: RE: WAW dependency messages
Message-Id: <marc-linux-ia64-106668880406921@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106625678318659@msgid-missing>
In-Reply-To: <marc-linux-ia64-106625678318659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-10-15 at 18:34, Chen, Kenneth W wrote:
> Oddly enough, "as test.S" doesn't have warning message, but "as -x
> test.S" does.  gcc is execve with "as -x" which triggers the warning
> message.

GNU as only does DV checking if the -x option is specified.

The DV checking stuff was never properly finished.  It should be enabled
by default.  And we should emit errors instead of warnings for provable
DVs.  However, if we did that, we would then have the problem that false
positives from bugs would prevent the compiler from working.  So we
would have to add an option to disable DV checking and have the compiler
emit it.  But then we would have the problem that the compiler output
would not get any DV checking from the assembler, which is a worse
problem than what we have now.  We really need to get the bugs fixed
first, and then emit errors by default for DVs.  I'm glad to see that HJ
has time to work on these problems.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

