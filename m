From: Jim Wilson <wilson@tuliptree.org>
Date: Thu, 06 Mar 2003 19:14:05 +0000
Subject: Re: [Linux-ia64] compiling 2.5.60 on hp simulator
Message-Id: <marc-linux-ia64-105590709805987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805984@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805984@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-03-06 at 08:41, Petur Thors wrote:
> gas message: error file number less then one.\

What gcc version are you using?  You can get this error if you try to
use an old gcc version with a new gas version.  This is because we made
a change to how the file name info is emitted for the DWARF2 debug info.
I suspect you are using a gcc-2.9x release, when you should be using a
gcc-3.x release.

Jim



