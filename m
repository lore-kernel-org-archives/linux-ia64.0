From: Matthew Wilcox <willy@debian.org>
Date: Mon, 12 May 2003 15:03:56 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] Increase size of user stack
Message-Id: <marc-linux-ia64-105590723705731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 12, 2003 at 10:59:38AM -0400, Martin Hicks wrote:
> Maybe I'm missing something, but what happens if a process is created
> using the default 2GB between the RBS and the stack and sometime
> later the process does a setrlimit to 100GB of stack.  How do the 
> stack and RBS get moved around to make enough room between the two
> start addresses?

They don't.  However, the new maximum would take effect for any newly
created children.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

