From: Matthew Wilcox <willy@debian.org>
Date: Tue, 01 Apr 2003 01:01:56 +0000
Subject: Re: [Linux-ia64] Another stupid logging question...
Message-Id: <marc-linux-ia64-105590723705371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705370@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705370@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 01, 2003 at 10:09:02AM +1000, Peter Chubb wrote:
> 
> Every time I boot my ZX2000, (which as it's a kernel development
> system is often) I get a little message that says the BMC event log is
> full.  I can read the log --- it's not very interesting --- but how do
> I clear it (and the forward progress log, too)?

You need to use IPMI to do it.  I forget which commands do that..

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

