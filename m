From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 26 Feb 2001 20:52:41 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005207@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>2. What is this new unwind stuff?

You probably want to know in the context of the kernel.  I can't answer that.

I can answer in the context of C++.  The unwind stuff is used for exception
handling.  When a program throws, we use the unwind stuff to unwind stack
frames back to where the exception handler (catch clause) is.  The unwind
data is similar in spirit to the DWARF2 frame info that is currently used by
most all other gcc targets.  It is basically the same data just encoded
differently.

The format of the data is documented in the Software Conventions and Runtime
Architecture manual, section 11.  The library interface for C++ EH is
documented in the psABI, section 6.  This hasn't been implemented yet, we are
working on it right now.

Jim

