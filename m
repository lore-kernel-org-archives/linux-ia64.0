From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 13 Aug 2001 20:48:11 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Noah" = Noah Romer <nromer@lsil.com> writes:

Noah> This is a kernel driver (linux/drivers/message/fusion). The
Noah> version in 2.4.7 isn't up to date (and doesn't contain the code
Noah> that uses rwlocks), but it's there, finally.

Ok, I saw Dave Miller checked it into his CVS tree yesterday or so.

Noah> Yep, but, for some reason, I've never gotten any complaints from
Noah> the compiler until I tried compiling on ia64. It's not a big
Noah> issue (especially since the subtracted value in this instance
Noah> should never be big enough that signed/unsigned will make a
Noah> diff), as I can just cast it to int. It just struck me as
Noah> strange that the compiler would now decide to issue a
Noah> warning. The rwlock bit is what's got me hung up.

The reason for this is most likely the compiler versions. For
Linux/ia64 you have to use at least gcc-2.96 to compile the
kernel. This compiler is a lot more picky about data types than the
older versions such as egcs-1.1.2/gcc-2.95 etc.

I'll leave the question about rwsem's to David ;)

Cheers
Jes

