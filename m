From: Jim Wilson <wilson@tuliptree.org>
Date: Wed, 07 May 2003 15:20:46 +0000
Subject: Re: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-05-07 at 13:40, navin wrote:
> 	I even tried copying the nue ia64-hp-something headers files and 
> giving gcc the option with --header to that directory but it messed up as 
> i previously mentioned

You never said how this failed.  Your previous message was about a build
using the non-existent --without-header configure option.  Since I don't
know what error you got when you used --with-headers, I can't help you.

> The problem is that building an alpha target is easy .But when i apply 
> the same rules to ia64 it breaks.GCC breaks.

Why does this not work for IA-64?  A build procedure that works for
alpha-linux should also work for ia64-linux.

Jim



