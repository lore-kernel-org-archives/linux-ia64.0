From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 17 Oct 2001 13:53:01 +0000
Subject: [Linux-ia64] Re: console_loglevel is broken on ia64
Message-Id: <marc-linux-ia64-105590698805359@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 17 Oct 2001 15:39:06 +0200, 
Jesper Juhl <juhl@eisenstein.dk> wrote:
>Keith Owens wrote:
>> kernel/printk.c has this abomination.
>> int console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
>> int default_message_loglevel = DEFAULT_MESSAGE_LOGLEVEL;
>> int minimum_console_loglevel = MINIMUM_CONSOLE_LOGLEVEL;
>> int default_console_loglevel = DEFAULT_CONSOLE_LOGLEVEL;
>> Does anybody fancy a small project to clean up these variables?
>
>I would like to give it a try. Seems like a good little project for one 
>who is trying to learn his way around the kernel :)

Good, I was hoping for somebody who wanted to get started on the
kernel.  It's all yours, unless somebody else does a patch first.

Ensure that you find all references to these variables and make them
all use the common #define, instead of random files declaring the
variables themselves.  Check all architectures as well.


