From: Grant Grundler <iod00d@hp.com>
Date: Mon, 12 Apr 2004 05:13:58 +0000
Subject: Re: 32 bit application on IA-64 Linux
Message-Id: <20040412051358.GA3095@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
In-Reply-To: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Apr 11, 2004 at 09:21:50PM -0700, Srikanta R wrote:
> Hi,
> 
> I need to compile a 32 bit application on a IA-64
> Linux system, that will run on IA-64 system. I didn't
> find any such option for the compiler on IA-64 Linux
> system. Can someone suggest how can I get this done ?

AFAIK, only HPUX supports a 32-bit ia64 environment with
the HPUX compiler/toolchain.

Either build it on an ia32 system and install the ia32 compat libs
on the ia64 machines (poor performance) or try to build the application
as a native 64-bit application (better performance).

Sorry, but the obvious question is If you really only need 32-bit,
why not run it on a fast ia32 machine?

I know a few other reasons one might port to ia64 besides 64-bit
but would like to hear your reasons.

grant
